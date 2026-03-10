import 'package:flutter/material.dart';
import 'models/conversation.dart';
import 'models/chat_config.dart';
import 'models/knowledge.dart';
import 'models/tag_item.dart';
import 'storage/conversation_storage.dart';
import 'storage/tag_storage.dart';
import 'storage/model_config_storage.dart';
import 'utils/date_utils.dart';

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

class FavoriteEntry {
  FavoriteEntry({
    required this.conversationId,
    required this.title,
    required this.preview,
    required this.detail,
    required this.createdAt,
  });

  final int conversationId;
  final String title;
  final String preview;
  final String detail;
  final DateTime createdAt;
}

class AppState extends ChangeNotifier {
  AppState({
    required this.conversations,
    required this.knowledgeFolders,
    required this.tags,
    Map<String, ChatConfig>? modelConfigs,
    this.activeVendor,
    int nextConvId = 1,
    int nextMsgId = 1,
  }) : modelConfigs = modelConfigs ?? <String, ChatConfig>{},
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
  final List<TagItem> tags;
  List<TagItem> get conversationSubdirectories {
    return conversationsSorted().map((Conversation c) {
      return TagItem(
        id: 'conv_${c.id}',
        name: c.title,
        color: const Color(0xFFF5F6FB),
      );
    }).toList();
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
          subdirectories: <TagItem>[],
        ),
      ],
      tags: tags,
      modelConfigs: modelConfigs,
      activeVendor: activeVendor,
      nextConvId: nextConvId,
      nextMsgId: nextMsgId,
    );
  }

  static List<DocFile> _seedFiles() {
    return <DocFile>[];
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

  List<FavoriteEntry> favoriteEntries() {
    final List<FavoriteEntry> items = <FavoriteEntry>[];
    for (final Conversation c in conversations) {
      for (final ChatMessage m in c.messages) {
        final MessageKnowledgeEntry? entry = m.knowledgeEntry;
        if (entry == null || !entry.fromFavorite) continue;
        items.add(
          FavoriteEntry(
            conversationId: c.id,
            title: entry.question,
            preview: _buildPreview(entry.answer),
            detail: entry.answer,
            createdAt: entry.collectedAt,
          ),
        );
      }
    }
    items.sort((FavoriteEntry a, FavoriteEntry b) {
      return b.createdAt.compareTo(a.createdAt);
    });
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
      ChatMessage(id: msgId, fromUser: true, text: text, time: DateTime.now()),
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
      ChatMessage(id: msgId, fromUser: false, text: text, time: DateTime.now()),
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

  void saveAssistantMessageToKnowledge({
    required int conversationId,
    required int messageId,
    String? tagName,
    bool fromFavorite = false,
  }) {
    final Conversation c = getConversationById(conversationId);
    final int messageIndex = c.messages.indexWhere(
      (ChatMessage item) => item.id == messageId,
    );
    if (messageIndex < 0) return;
    final ChatMessage target = c.messages[messageIndex];
    if (target.fromUser) return;

    final String answer = target.text.trim();
    if (answer.isEmpty) return;

    final String question = _findLatestUserQuestionBefore(
      c.messages,
      messageIndex,
      fallback: c.title,
    );
    final MessageKnowledgeEntry? oldEntry = target.knowledgeEntry;
    target.knowledgeEntry = MessageKnowledgeEntry(
      question: question,
      answer: answer,
      collectedAt: DateTime.now(),
      tagName: tagName ?? oldEntry?.tagName,
      fromFavorite: fromFavorite || (oldEntry?.fromFavorite ?? false),
    );

    notifyListeners();
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }

  List<DocFile> conversationKnowledgeFiles(int conversationId) {
    final Conversation c = getConversationById(conversationId);
    final List<DocFile> files = c.messages
        .where((ChatMessage m) => m.knowledgeEntry != null)
        .map((ChatMessage m) {
          final MessageKnowledgeEntry entry = m.knowledgeEntry!;
          return DocFile(
            title: entry.question,
            preview: _buildPreview(entry.answer),
            timeText: friendlyDate(entry.collectedAt),
            detail: entry.answer,
            createdAt: entry.collectedAt,
            tagName: entry.tagName,
          );
        })
        .toList();
    files.sort((DocFile a, DocFile b) {
      final DateTime aTime =
          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime =
          b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return files;
  }

  String _findLatestUserQuestionBefore(
    List<ChatMessage> messages,
    int index, {
    required String fallback,
  }) {
    for (int i = index - 1; i >= 0; i--) {
      final ChatMessage message = messages[i];
      if (message.fromUser && message.text.trim().isNotEmpty) {
        return message.text.trim();
      }
    }
    return fallback;
  }

  String _buildPreview(String text) {
    const int maxLength = 42;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void updateTag({required String oldName, required String newName}) {
    final String normalized = newName.trim();
    if (normalized.isEmpty || oldName == normalized) return;
    if (tags.any((TagItem t) => t.name == normalized)) return;

    for (final TagItem tag in tags) {
      if (tag.name == oldName) {
        tag.name = normalized;
        tag.id = normalized;
      }
    }

    for (final Conversation c in conversations) {
      for (final ChatMessage m in c.messages) {
        for (int i = 0; i < m.tags.length; i++) {
          if (m.tags[i] == oldName) {
            m.tags[i] = normalized;
          }
        }
        if (m.knowledgeEntry?.tagName == oldName) {
          m.knowledgeEntry!.tagName = normalized;
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
    if (tags.any((TagItem t) => t.name == normalized)) return;

    tags.add(
      TagItem(id: normalized, name: normalized, color: const Color(0xFFF0F2FF)),
    );
    notifyListeners();
    TagStorage.save(tags);
  }

  void deleteTag(String tagId) {
    tags.removeWhere((TagItem t) => t.id == tagId);
    for (final Conversation c in conversations) {
      for (final ChatMessage m in c.messages) {
        m.tags.removeWhere((String t) => t == tagId);
        if (m.knowledgeEntry?.tagName == tagId) {
          m.knowledgeEntry!.tagName = null;
        }
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
      ChatMessage(id: msgId, fromUser: false, text: '', time: DateTime.now()),
    );
    c.updatedAt = DateTime.now();
    notifyListeners();
    return msgId;
  }

  void appendToMessage(int conversationId, int messageId, String chunk) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m = c.messages.firstWhere(
      (ChatMessage msg) => msg.id == messageId,
    );
    m.text += chunk;
    c.preview = m.text.length > 50 ? '${m.text.substring(0, 50)}...' : m.text;
    notifyListeners();
  }

  void updateMessageText(int conversationId, int messageId, String text) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m = c.messages.firstWhere(
      (ChatMessage msg) => msg.id == messageId,
    );
    m.text = text;
    c.preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    notifyListeners();
  }

  void saveConversations() {
    ConversationStorage.save(conversations, _nextConvId, _nextMsgId);
  }
}
