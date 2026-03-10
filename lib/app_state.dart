import 'package:flutter/material.dart';
import 'models/conversation.dart';
import 'models/chat_config.dart';
import 'models/knowledge.dart';
import 'models/tag_item.dart';
import 'storage/conversation_storage.dart';
import 'storage/tag_storage.dart';
import 'storage/model_config_storage.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final AppStateScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

class AppState extends ChangeNotifier {
  AppState({
    required this.conversations,
    required this.knowledgeFolders,
    Map<String, ChatConfig>? modelConfigs,
    this.activeVendor,
    int nextConvId = 1,
    int nextMsgId = 1,
  })  : modelConfigs = modelConfigs ?? <String, ChatConfig>{},
        _nextConvId = nextConvId,
        _nextMsgId = nextMsgId;

  int _nextConvId;
  int _nextMsgId;
  Map<String, ChatConfig> modelConfigs;
  String? activeVendor;

  int _allocConvId() => _nextConvId++;
  int _allocMsgId() => _nextMsgId++;
  final List<Conversation> conversations;
  final List<KnowledgeFolder> knowledgeFolders;
  List<TagItem> get tags {
    final Map<String, TagItem> merged = <String, TagItem>{};
    for (final KnowledgeFolder folder in knowledgeFolders) {
      for (final TagItem tag in folder.subdirectories) {
        merged.putIfAbsent(
          tag.name,
          () => TagItem(id: tag.name, name: tag.name, color: tag.color),
        );
      }
    }
    return merged.values.toList();
  }

  factory AppState.initial({
    required List<TagItem> tags,
    required Map<String, ChatConfig> modelConfigs,
    required String? activeVendor,
    required List<Conversation> conversations,
    required int nextConvId,
    required int nextMsgId,
  }) {
    return AppState(
      conversations: conversations,
      knowledgeFolders: <KnowledgeFolder>[
        KnowledgeFolder(
          name: '默认',
          files: _seedFiles(),
          subdirectories: tags,
        ),
      ],
      modelConfigs: modelConfigs,
      activeVendor: activeVendor,
      nextConvId: nextConvId,
      nextMsgId: nextMsgId,
    );
  }

  static List<DocFile> _seedFiles() {
    return <DocFile>[
      DocFile(
        title: '广州旅游攻略1',
        preview: '我现在要帮你把搜索图库的手柄变成白色我现在要帮你把搜索图库的手柄变成白...',
        timeText: '1月6日 12:09',
      ),
      DocFile(
        title: '广州旅游要去这些地方',
        preview: '我现在要帮你把搜索图库的手柄变成白色',
        timeText: '1月6日 12:09',
      ),
      DocFile(
        title: '你还没去过广州吗',
        preview: '我现在要帮你把搜索图库的手柄变成白色我现在要帮你把搜索图库的手柄变成白...',
        timeText: '1月6日 12:09',
      ),
    ];
  }

  List<Conversation> conversationsSorted({String query = ''}) {
    final String q = query.trim().toLowerCase();
    final List<Conversation> items = conversations.where((Conversation c) {
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.preview.toLowerCase().contains(q);
    }).toList();
    items.sort(
      (Conversation a, Conversation b) => b.updatedAt.compareTo(a.updatedAt),
    );
    return items;
  }

  List<Conversation> favoriteConversations() {
    final List<Conversation> items = conversations
        .where((Conversation c) => c.favorite)
        .toList();
    items.sort(
      (Conversation a, Conversation b) => b.updatedAt.compareTo(a.updatedAt),
    );
    return items;
  }

  Conversation createConversation() {
    final int convId = _allocConvId();
    final int msgId = _allocMsgId();
    final Conversation item = Conversation(
      id: convId,
      title: '新建会话',
      preview: '开始新的对话吧',
      updatedAt: DateTime.now(),
      messages: <ChatMessage>[
        ChatMessage(
          id: msgId,
          fromUser: false,
          text: '你好，我是你的 AI 助手，有什么可以帮你？',
          time: DateTime.now(),
        ),
      ],
    );
    conversations.add(item);
    notifyListeners();
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
    return item;
  }

  Conversation getConversationById(int id) {
    return conversations.firstWhere((Conversation c) => c.id == id);
  }

  void touchConversation(int conversationId, {String? newPreview}) {
    final Conversation c = getConversationById(conversationId);
    if (newPreview != null && newPreview.isNotEmpty) {
      c.preview = newPreview;
    }
    c.updatedAt = DateTime.now();
    notifyListeners();
  }

  int addUserMessage(int conversationId, String text) {
    final Conversation c = getConversationById(conversationId);
    final int msgId = _allocMsgId();
    c.messages.add(
      ChatMessage(
        id: msgId,
        fromUser: true,
        text: text,
        time: DateTime.now(),
      ),
    );
    c.preview = text;
    c.updatedAt = DateTime.now();
    notifyListeners();
    return msgId;
  }

  int addAssistantMessage(int conversationId, String text) {
    final Conversation c = getConversationById(conversationId);
    final int msgId = _allocMsgId();
    c.messages.add(
      ChatMessage(
        id: msgId,
        fromUser: false,
        text: text,
        time: DateTime.now(),
      ),
    );
    c.preview = text;
    c.updatedAt = DateTime.now();
    notifyListeners();
    return msgId;
  }

  void toggleConversationFavorite(int conversationId) {
    final Conversation c = getConversationById(conversationId);
    c.favorite = !c.favorite;
    notifyListeners();
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }

  void renameConversation(int conversationId, String title) {
    final String normalized = title.trim();
    if (normalized.isEmpty) return;
    final Conversation c = getConversationById(conversationId);
    c.title = normalized;
    c.updatedAt = DateTime.now();
    notifyListeners();
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }

  void assignTagToMessage({
    required int conversationId,
    required int messageId,
    required String tagName,
  }) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m = c.messages.firstWhere(
      (ChatMessage item) => item.id == messageId,
    );
    if (!m.tags.contains(tagName)) {
      m.tags.add(tagName);
      notifyListeners();
      ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
    }
  }

  void updateTag({required String oldName, required String newName}) {
    final String normalized = newName.trim();
    if (normalized.isEmpty || oldName == normalized) return;
    if (tags.any((TagItem t) => t.name == normalized)) return;

    for (final KnowledgeFolder folder in knowledgeFolders) {
      for (final TagItem subdir in folder.subdirectories) {
        if (subdir.name == oldName) {
          subdir.name = normalized;
          subdir.id = normalized;
        }
      }
    }

    for (final Conversation c in conversations) {
      for (final ChatMessage m in c.messages) {
        for (int i = 0; i < m.tags.length; i++) {
          if (m.tags[i] == oldName) {
            m.tags[i] = normalized;
          }
        }
      }
    }
    notifyListeners();
    TagStorage.save(tags);
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }

  void addTag(String name) {
    final String normalized = name.trim();
    if (normalized.isEmpty) return;
    if (knowledgeFolders.isEmpty) return;
    if (tags.any((TagItem t) => t.name == normalized)) return;

    knowledgeFolders.first.subdirectories.add(
      TagItem(id: normalized, name: normalized, color: const Color(0xFFF0F2FF)),
    );
    notifyListeners();
    TagStorage.save(tags);
  }

  void deleteTag(String tagId) {
    for (final KnowledgeFolder folder in knowledgeFolders) {
      folder.subdirectories.removeWhere((TagItem t) => t.id == tagId);
    }
    for (final Conversation c in conversations) {
      for (final ChatMessage m in c.messages) {
        m.tags.removeWhere((String t) => t == tagId);
      }
    }
    notifyListeners();
    TagStorage.save(tags);
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }

  void saveModelConfig(ChatConfig config) {
    modelConfigs[config.vendor] = config;
    notifyListeners();
    ModelConfigStorage.save(modelConfigs, activeVendor);
  }

  void setActiveVendor(String vendor) {
    activeVendor = vendor;
    notifyListeners();
    ModelConfigStorage.save(modelConfigs, activeVendor);
  }

  void removeModelConfig(String vendor) {
    modelConfigs.remove(vendor);
    if (activeVendor == vendor) activeVendor = null;
    notifyListeners();
    ModelConfigStorage.save(modelConfigs, activeVendor);
  }

  int addStreamingMessage(int conversationId) {
    final Conversation c = getConversationById(conversationId);
    final int msgId = _allocMsgId();
    c.messages.add(
      ChatMessage(
        id: msgId,
        fromUser: false,
        text: '',
        time: DateTime.now(),
      ),
    );
    c.updatedAt = DateTime.now();
    notifyListeners();
    return msgId;
  }

  void appendToMessage(int conversationId, int messageId, String chunk) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m =
        c.messages.firstWhere((ChatMessage msg) => msg.id == messageId);
    m.text += chunk;
    c.preview = m.text.length > 50 ? '${m.text.substring(0, 50)}...' : m.text;
    notifyListeners();
  }

  void updateMessageText(int conversationId, int messageId, String text) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m =
        c.messages.firstWhere((ChatMessage msg) => msg.id == messageId);
    m.text = text;
    c.preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    notifyListeners();
  }

  void saveConversations() {
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }
}
