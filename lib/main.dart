import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState.seed(),
      child: MaterialApp(
        title: 'AI Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C84FF)),
          scaffoldBackgroundColor: Colors.white,
          dividerColor: const Color(0xFFF0F1F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1F2430),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
            ),
          ),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}

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
  AppState({required this.conversations, required this.knowledgeFolders});

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

  factory AppState.seed() {
    final now = DateTime.now();
    return AppState(
      conversations: <Conversation>[
        Conversation(
          id: 'c1',
          title: '图中人物替换',
          preview: '[卡片]',
          updatedAt: now.subtract(const Duration(minutes: 5)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c2',
          title: '生成职业培训背景图',
          preview: '我现在要帮你把搜索图库的手柄变成白色',
          updatedAt: now.subtract(const Duration(minutes: 10)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c3',
          title: '图片分辨率变大',
          preview: '[卡片]',
          updatedAt: now.subtract(const Duration(minutes: 15)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c4',
          title: '替换灯泡',
          preview: '我会把整个图标部分替换成相同质感的云.',
          updatedAt: now.subtract(const Duration(minutes: 20)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c5',
          title: '优化图片为科技风格',
          preview: '[卡片]',
          updatedAt: now.subtract(const Duration(minutes: 25)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c6',
          title: '图片分辨率变大',
          preview: '我将为生成仅包含搜索图标的图片，保持与原图相...',
          updatedAt: now.subtract(const Duration(minutes: 30)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c7',
          title: '图片分辨率变大',
          preview: '[卡片]',
          updatedAt: now.subtract(const Duration(minutes: 35)),
          messages: _seedMessages(),
        ),
        Conversation(
          id: 'c8',
          title: '图片分辨率变大',
          preview: '我现在要帮你把搜索图标的手柄变成白色.',
          updatedAt: now.subtract(const Duration(minutes: 40)),
          messages: _seedMessages(),
        ),
      ],
      knowledgeFolders: <KnowledgeFolder>[
        KnowledgeFolder(
          name: '默认',
          files: _seedFiles(),
          subdirectories: <TagItem>[
            TagItem(id: '学习', name: '学习', color: const Color(0xFFF0F2FF)),
            TagItem(id: '工作', name: '工作', color: const Color(0xFFEEF9F1)),
            TagItem(id: '旅游', name: '旅游', color: const Color(0xFFFAFAEB)),
            TagItem(id: '其他', name: '其他', color: const Color(0xFFEEF7FF)),
            TagItem(id: '生活', name: '生活', color: const Color(0xFFEFFAF6)),
            TagItem(id: '阅读', name: '阅读', color: const Color(0xFFF0FAFF)),
          ],
        ),
      ],
    );
  }

  static List<ChatMessage> _seedMessages() {
    return <ChatMessage>[
      ChatMessage(
        id: 'm1',
        fromUser: true,
        text: '请帮我写一份产品说明书',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ChatMessage(
        id: 'm2',
        fromUser: false,
        text:
            '可以，我直接给你一份通用、正规、可直接用在抖店里的产品说明书模板，你把产品名填进去就能用。\n\n产品说明书（通用标准版）\n\n一、产品名称\n\nXXX（请替换成你的产品名）\n\n二、产品参数\n\n· 品牌：XXX\n· 材质/成分：XXX\n· 规格尺寸：XXX\n· 颜色款式：XXX\n· 适用场景：居家、办公、外出、送礼等\n· 生产标准：按国家相关标准执行\n\n三、产品功能与特点\n\n· 卖点 1：XXX\n· 卖点 2：XXX\n· 卖点 3：XXX',
        time: DateTime.now(),
      ),
    ];
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
    final Conversation item = Conversation(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      title: '新建会话',
      preview: '开始新的对话吧',
      updatedAt: DateTime.now(),
      messages: <ChatMessage>[
        ChatMessage(
          id: 'm_welcome',
          fromUser: false,
          text: '你好，我是你的 AI 助手，有什么可以帮你？',
          time: DateTime.now(),
        ),
      ],
    );
    conversations.add(item);
    notifyListeners();
    return item;
  }

  Conversation getConversationById(String id) {
    return conversations.firstWhere((Conversation c) => c.id == id);
  }

  void touchConversation(String conversationId, {String? newPreview}) {
    final Conversation c = getConversationById(conversationId);
    if (newPreview != null && newPreview.isNotEmpty) {
      c.preview = newPreview;
    }
    c.updatedAt = DateTime.now();
    notifyListeners();
  }

  void addUserMessage(String conversationId, String text) {
    final Conversation c = getConversationById(conversationId);
    c.messages.add(
      ChatMessage(
        id: 'm${DateTime.now().microsecondsSinceEpoch}',
        fromUser: true,
        text: text,
        time: DateTime.now(),
      ),
    );
    c.preview = text;
    c.updatedAt = DateTime.now();
    notifyListeners();
  }

  void addAssistantMessage(String conversationId, String text) {
    final Conversation c = getConversationById(conversationId);
    c.messages.add(
      ChatMessage(
        id: 'm${DateTime.now().microsecondsSinceEpoch}',
        fromUser: false,
        text: text,
        time: DateTime.now(),
      ),
    );
    c.preview = text;
    c.updatedAt = DateTime.now();
    notifyListeners();
  }

  void toggleConversationFavorite(String conversationId) {
    final Conversation c = getConversationById(conversationId);
    c.favorite = !c.favorite;
    notifyListeners();
  }

  void assignTagToMessage({
    required String conversationId,
    required String messageId,
    required String tagName,
  }) {
    final Conversation c = getConversationById(conversationId);
    final ChatMessage m = c.messages.firstWhere(
      (ChatMessage item) => item.id == messageId,
    );
    if (!m.tags.contains(tagName)) {
      m.tags.add(tagName);
      notifyListeners();
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
  }
}

class Conversation {
  Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.messages,
    this.favorite = false,
  });

  final String id;
  String title;
  String preview;
  DateTime updatedAt;
  bool favorite;
  final List<ChatMessage> messages;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fromUser,
    required this.text,
    required this.time,
  });

  final String id;
  final bool fromUser;
  final String text;
  final DateTime time;
  final List<String> tags = <String>[];
}

class KnowledgeFolder {
  KnowledgeFolder({
    required this.name,
    required this.files,
    required this.subdirectories,
  });

  final String name;
  final List<DocFile> files;
  final List<TagItem> subdirectories;
}

class DocFile {
  DocFile({required this.title, required this.preview, required this.timeText});

  final String title;
  final String preview;
  final String timeText;
}

class TagItem {
  TagItem({required this.id, required this.name, required this.color});

  String id;
  String name;
  final Color color;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreeProtocol = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final bool validUser = _usernameController.text.trim() == 'admin';
    final bool validPwd = _passwordController.text == 'admin';

    if (!_agreeProtocol) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先阅读并同意服务协议')));
      return;
    }

    if (validUser && validPwd) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShellPage()),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('用户名或密码错误，请输入 admin / admin')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/login_background_top.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 220),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildInput(controller: _usernameController, hint: '请输入账号'),
                    const SizedBox(height: 16),
                    _buildInput(
                      controller: _passwordController,
                      hint: '请输入密码',
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF9198A8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _agreeProtocol,
                          activeColor: const Color(0xFF5A8FFF),
                          visualDensity: VisualDensity.compact,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreeProtocol = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: '我已阅读并同意 ',
                              style: TextStyle(
                                color: Color(0xFF8A93A6),
                                fontSize: 13,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '《用户服务协议》',
                                  style: TextStyle(color: Color(0xFF5A8FFF)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF6B8AFF),
                              Color(0xFF4DA0FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            '登录',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '忘记密码?',
                          style: TextStyle(
                            color: Color(0xFFB0B5C2),
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '验证码登录',
                          style: TextStyle(
                            color: Color(0xFF4C84FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC2C8D5), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF5F7FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Color(0xFF2B3240)),
    );
  }
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomePage(),
      const KnowledgePage(),
      const MinePage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        height: 84,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F1F5), width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(0, '首页', 'assets/main_bottom_home_icon.png'),
            _buildNavItem(1, '知识库', 'assets/main_bottom_knowledge_icon.png'),
            _buildNavItem(2, '我的', 'assets/main_bottom_mine_icon.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String assetPath) {
    final bool isSelected = _index == index;
    final Color color = isSelected
        ? const Color(0xFF1D2330)
        : const Color(0xFFBFC4D0);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              assetPath,
              width: 28,
              height: 28,
              // Removed color filter to ensure original icon is visible if color filter fails
              // Or use color only if the icons are monochrome
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<Conversation> items = app.conversationsSorted(query: _query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('对话'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D2330),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final Conversation c = app.createConversation();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(conversationId: c.id),
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFF4C84FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                onChanged: (String value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1D2330)),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C9D5),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC4C9D5),
                    size: 22,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 22,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: const Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    color: Color(0xFFF5F6F8),
                    indent: 90,
                  ),
              itemBuilder: (BuildContext context, int index) {
                final Conversation item = items[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatPage(conversationId: item.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/main_list_icon_${(index % 7) + 1}.png',
                          width: 56, // Increased from 48
                          height: 56, // Increased from 48
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color(0xFF1D2330),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8E95A6),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showInputPanel = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final Conversation conversation = app.getConversationById(
      widget.conversationId,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.remove, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('对话', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            onPressed: () => setState(() => _showInputPanel = !_showInputPanel),
            icon: const Icon(Icons.add_circle, color: Color(0xFF4C84FF)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '17:23',
              style: TextStyle(color: Color(0xFF9FA5B3), fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: conversation.messages.length,
              itemBuilder: (BuildContext context, int index) {
                final ChatMessage message = conversation.messages[index];
                final bool fromUser = message.fromUser;
                final Color bubbleColor = fromUser
                    ? const Color(0xFF4C84FF)
                    : const Color(0xFFF5F6FA);
                final Color textColor = fromUser
                    ? Colors.white
                    : const Color(0xFF1F2633);

                return Align(
                  alignment: fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onLongPress: fromUser
                          ? null
                          : () => _onLongPressAssistantMessage(
                              app,
                              conversation.id,
                              message,
                            ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  height: 1.55,
                                  fontWeight: fromUser
                                      ? FontWeight.w600
                                      : FontWeight.w600,
                                ),
                              ),
                              if (message.tags.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: message.tags
                                      .map(
                                        (String tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9F1FF),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF4C84FF),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputBar(app, conversation),
          if (_showInputPanel) _buildInputPanel(app, conversation),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppState app, Conversation conversation) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDF0F6)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              app.addUserMessage(conversation.id, '[图片] 拍照上传');
              app.addAssistantMessage(conversation.id, '已收到图片，你希望我做什么处理？');
            },
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF4A4F5D),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '发消息或者按住说话',
                hintStyle: TextStyle(color: Color(0xFFB0B5C2), fontSize: 15),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendText(app, conversation.id),
            ),
          ),
          IconButton(
            onPressed: () {
              app.addUserMessage(conversation.id, '[语音] 语音输入');
              app.addAssistantMessage(conversation.id, '语音已转文字并处理完成。');
            },
            icon: const Icon(
              Icons.graphic_eq_outlined,
              color: Color(0xFF4A4F5D),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showInputPanel = !_showInputPanel),
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF4A4F5D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(AppState app, Conversation conversation) {
    final List<Map<String, dynamic>> actions = <Map<String, dynamic>>[
      <String, dynamic>{
        'icon': Icons.camera_alt,
        'label': '相机',
        'msg': '[图片] 相机拍摄',
      },
      <String, dynamic>{'icon': Icons.image, 'label': '相册', 'msg': '[图片] 相册选择'},
      <String, dynamic>{
        'icon': Icons.attach_file,
        'label': '文件',
        'msg': '[文件] 文档上传',
      },
      <String, dynamic>{
        'icon': Icons.phone,
        'label': '打电话',
        'msg': '[系统] 发起电话',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFF2F7))),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((Map<String, dynamic> action) {
              return GestureDetector(
                onTap: () {
                  app.addUserMessage(conversation.id, action['msg'] as String);
                  app.addAssistantMessage(
                    conversation.id,
                    '已接收${action['label']}内容。',
                  );
                },
                child: SizedBox(
                  width: 70,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: const Color(0xFF4A4F5D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(action['label'] as String),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, int index) {
                return Container(
                  width: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.lightBlue.shade100,
                        Colors.green.shade100,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendText(AppState app, String conversationId) {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    app.addUserMessage(conversationId, value);
    app.addAssistantMessage(conversationId, '已收到：$value\n\n这是模拟模型回复。');
    _controller.clear();
  }

  Future<void> _onLongPressAssistantMessage(
    AppState app,
    String conversationId,
    ChatMessage message,
  ) async {
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.outlined_flag),
                title: const Text('打标签', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('tag'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('收藏', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('favorite'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('导出', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('export'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'tag') {
      await _showTagSheet(context, conversationId, message.id);
    } else if (action == 'favorite') {
      app.toggleConversationFavorite(conversationId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已收藏会话')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已导出内容（示例）')));
    }
  }

  Future<void> _showTagSheet(
    BuildContext context,
    String conversationId,
    String messageId,
  ) async {
    String selectedTag = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          '打标签',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '标签类型',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final String? result = await _showTagSelector(context);
                      if (result != null) {
                        setModalState(() => selectedTag = result);
                      }
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedTag.isEmpty ? '请选择' : selectedTag,
                        style: const TextStyle(
                          color: Color(0xFF7E8799),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setModalState(() => selectedTag = ''),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('重置'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final AppState latestApp = AppStateScope.of(
                              context,
                            );
                            final bool exists = latestApp.tags.any(
                              (TagItem t) => t.name == selectedTag,
                            );
                            if (selectedTag.isNotEmpty && exists) {
                              latestApp.assignTagToMessage(
                                conversationId: conversationId,
                                messageId: messageId,
                                tagName: selectedTag,
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C84FF),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('确定'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showTagSelector(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    String current = app.tags.isNotEmpty ? app.tags.first.name : '';

    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final List<TagItem> tags = AppStateScope.of(context).tags;
            if (tags.isEmpty) {
              current = '';
            } else if (!tags.any((TagItem tag) => tag.name == current)) {
              current = tags.first.name;
            }
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        const Expanded(
                          child: Text(
                            '选择标签类型',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(current),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: 220,
                    child: tags.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无可选标签',
                              style: TextStyle(
                                color: Color(0xFF9DA5B5),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView(
                            children: tags.map((TagItem tag) {
                              final bool selected = current == tag.name;
                              return ListTile(
                                title: Text(tag.name),
                                trailing: selected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF4C84FF),
                                      )
                                    : null,
                                onTap: () => setState(() => current = tag.name),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: Color(0xFF1F2430),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/mine_user_avatar.png',
              width: 140,
              height: 140,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '小智AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2330),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(height: 1, color: Color(0xFFF5F6F8)),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyFavoritesPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/mine_favorite_icon.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '我的收藏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2330),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFC4D0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
        ],
      ),
    );
  }
}

class MyFavoritesPage extends StatelessWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Conversation> items = AppStateScope.of(
      context,
    ).favoriteConversations();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的收藏',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Conversation item = items[index];
          return ListTile(
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                  item.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF8A93A6)),
                ),
                const SizedBox(height: 8),
                Text(
                  _friendlyDate(item.updatedAt),
                  style: const TextStyle(color: Color(0xFFB0B5C2)),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(conversationId: item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D2330),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              height: 44,
              child: TextField(
                style: const TextStyle(fontSize: 16, color: Color(0xFF1D2330)),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C9D5),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC4C9D5),
                    size: 22,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 22,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: const Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          _entryTile(
            assetPath: 'assets/knowledge_folder_icon.png',
            title: '文件夹',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FolderListPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          _entryTile(
            assetPath: 'assets/knowledge_tag_icon.png',
            title: '标签',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TagListPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          _entryTile(
            assetPath: 'assets/knowledge_preview_icon.png',
            title: '文件预览',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FileListPage(title: '文件名称'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _entryTile({
    required String assetPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: <Widget>[
            Image.asset(assetPath, width: 50, height: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2330),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBFC4D0), size: 24),
          ],
        ),
      ),
    );
  }
}

class FolderListPage extends StatelessWidget {
  const FolderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<TagItem> tagDirs = app.tags;
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件夹'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D2330),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              height: 44,
              child: TextField(
                style: const TextStyle(fontSize: 16, color: Color(0xFF1D2330)),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C9D5),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC4C9D5),
                    size: 22,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 22,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: const Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tagDirs.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    color: Color(0xFFF5F6F8),
                    indent: 84,
                  ),
              itemBuilder: (BuildContext context, int index) {
                final TagItem tagDir = tagDirs[index];
                final KnowledgeFolder? ownerFolder = app.knowledgeFolders
                    .cast<KnowledgeFolder?>()
                    .firstWhere(
                      (KnowledgeFolder? folder) =>
                          folder != null &&
                          folder.subdirectories.any(
                            (TagItem t) => t.name == tagDir.name,
                          ),
                      orElse: () => null,
                    );
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FileListPage(
                          title: tagDir.name,
                          files: ownerFolder?.files,
                          subdirectories: <TagItem>[tagDir],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/knowledge_folder_icon.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            tagDir.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D2330),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFBFC4D0),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FileListPage extends StatelessWidget {
  const FileListPage({
    super.key,
    required this.title,
    this.files,
    this.subdirectories,
  });

  final String title;
  final List<DocFile>? files;
  final List<TagItem>? subdirectories;

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<DocFile> list =
        files ??
        (app.knowledgeFolders.isNotEmpty
            ? app.knowledgeFolders.first.files
            : <DocFile>[]);
    final List<TagItem> tagDirs =
        subdirectories ??
        (app.knowledgeFolders.isNotEmpty
            ? app.knowledgeFolders.first.subdirectories
            : <TagItem>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: <Widget>[
          if (tagDirs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tagDirs
                    .map(
                      (TagItem tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tag.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E6676),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ...List<Widget>.generate(list.length, (int index) {
            final DocFile file = list[index];
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    file.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      Text(
                        file.preview,
                        style: const TextStyle(color: Color(0xFF8A93A6)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file.timeText,
                        style: const TextStyle(color: Color(0xFFB0B5C2)),
                      ),
                    ],
                  ),
                ),
                if (index != list.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  String? _selectedTagId;

  Future<void> _showHalfCard(BuildContext context, Widget child) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.62,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _showHalfCard(context, const TagInsertPage());
              setState(() {});
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: app.tags.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (_, int index) {
              final TagItem tag = app.tags[index];
              final bool selected = _selectedTagId == tag.id;
              return GestureDetector(
                onLongPress: () => setState(() => _selectedTagId = tag.id),
                onTap: () => setState(() => _selectedTagId = null),
                child: Container(
                  decoration: BoxDecoration(
                    color: tag.color,
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(color: const Color(0xFF4C84FF), width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Color(0xFF4C84FF),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_selectedTagId != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEFF2F7))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () async {
                        final TagItem tag = app.tags.firstWhere(
                          (TagItem t) => t.id == _selectedTagId,
                        );
                        await _showHalfCard(
                          context,
                          TagEditPage(tagId: tag.id, initialName: tag.name),
                        );
                        setState(() => _selectedTagId = null);
                      },
                      icon: const Icon(Icons.edit_note),
                      label: const Text('编辑'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        app.deleteTag(_selectedTagId!);
                        setState(() => _selectedTagId = null);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('删除'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TagEditPage extends StatefulWidget {
  const TagEditPage({
    super.key,
    required this.tagId,
    required this.initialName,
  });

  final String tagId;
  final String initialName;

  @override
  State<TagEditPage> createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '编辑',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F5)),
        ),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4C84FF),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('取消'),
        ),
        leadingWidth: 70,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final String value = _controller.text.trim();
              if (value.isNotEmpty) {
                AppStateScope.of(
                  context,
                ).updateTag(oldName: widget.initialName, newName: value);
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4C84FF),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/tag_edit_top_icon.png',
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 42),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7383),
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入标签名',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFC3C9D6),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FB),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    final String value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      AppStateScope.of(
                        context,
                      ).updateTag(oldName: widget.initialName, newName: value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagInsertPage extends StatefulWidget {
  const TagInsertPage({super.key});

  @override
  State<TagInsertPage> createState() => _TagInsertPageState();
}

class _TagInsertPageState extends State<TagInsertPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '新增',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F5)),
        ),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4C84FF),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('取消'),
        ),
        leadingWidth: 70,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final String value = _controller.text.trim();
              if (value.isNotEmpty) {
                AppStateScope.of(context).addTag(value);
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4C84FF),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/tag_edit_top_icon.png',
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 42),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7383),
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入新的标签名',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFC3C9D6),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FB),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    final String value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      AppStateScope.of(context).addTag(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _friendlyDate(DateTime time) {
  return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
