import 'package:flutter/material.dart';
import 'models/conversation.dart';
import 'models/chat_config.dart';
import 'models/tag_item.dart';
import 'app_state.dart';
import 'storage/conversation_storage.dart';
import 'storage/tag_storage.dart';
import 'storage/model_config_storage.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<TagItem> tags = await TagStorage.load();
  final (:Map<String, ChatConfig> configs, :String? activeVendor) =
      await ModelConfigStorage.load();
  final (
    :List<Conversation> conversations,
    :int nextConvId,
    :int nextMsgId,
  ) = await ConversationStorage.load();
  runApp(MyApp(
    initialTags: tags,
    initialConfigs: configs,
    initialActiveVendor: activeVendor,
    initialConversations: conversations,
    initialNextConvId: nextConvId,
    initialNextMsgId: nextMsgId,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialTags,
    required this.initialConfigs,
    required this.initialActiveVendor,
    required this.initialConversations,
    required this.initialNextConvId,
    required this.initialNextMsgId,
  });

  final List<TagItem> initialTags;
  final Map<String, ChatConfig> initialConfigs;
  final String? initialActiveVendor;
  final List<Conversation> initialConversations;
  final int initialNextConvId;
  final int initialNextMsgId;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState.initial(
        tags: initialTags,
        modelConfigs: initialConfigs,
        activeVendor: initialActiveVendor,
        conversations: initialConversations,
        nextConvId: initialNextConvId,
        nextMsgId: initialNextMsgId,
      ),
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
