import 'package:flutter/material.dart';
import 'models/conversation.dart';
import 'models/chat_config.dart';
import 'models/tag_item.dart';
import 'models/vendor_profile.dart';
import 'app_state.dart';
import 'storage/conversation_storage.dart';
import 'storage/tag_storage.dart';
import 'storage/model_config_storage.dart';
import 'storage/local_auth_storage.dart';
import 'testing/test_account_feature.dart';
import 'pages/login_page.dart';
import 'pages/main_shell_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<TagItem> tags = await TagStorage.load();
  final ({
    Map<String, ChatConfig> configs,
    String? activeVendor,
    List<VendorProfile> vendors,
  })
  loadedModelConfig = await ModelConfigStorage.load();
  Map<String, ChatConfig> initialConfigs = Map<String, ChatConfig>.from(
    loadedModelConfig.configs,
  );
  String? initialActiveVendor = loadedModelConfig.activeVendor;
  List<VendorProfile> initialVendors = List<VendorProfile>.from(
    loadedModelConfig.vendors,
  );
  final (:List<Conversation> conversations, :int nextConvId, :int nextMsgId) =
      await ConversationStorage.load();
  final String? loginPhone = await LocalAuthStorage.loadLoginPhone();
  final ({
    Map<String, ChatConfig> configs,
    String? activeVendor,
    List<VendorProfile> vendors,
  })
  patchedModelConfig = TestAccountFeature.applyPresetForLoginPhone(
    loginPhone: loginPhone,
    configs: initialConfigs,
    activeVendor: initialActiveVendor,
    vendors: initialVendors,
  );
  initialConfigs = patchedModelConfig.configs;
  initialActiveVendor = patchedModelConfig.activeVendor;
  initialVendors = patchedModelConfig.vendors;
  final bool hasLoginSession = loginPhone != null;
  runApp(
    MyApp(
      initialTags: tags,
      initialConfigs: initialConfigs,
      initialActiveVendor: initialActiveVendor,
      initialVendors: initialVendors,
      initialConversations: conversations,
      initialNextConvId: nextConvId,
      initialNextMsgId: nextMsgId,
      hasLoginSession: hasLoginSession,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialTags,
    required this.initialConfigs,
    required this.initialActiveVendor,
    required this.initialVendors,
    required this.initialConversations,
    required this.initialNextConvId,
    required this.initialNextMsgId,
    required this.hasLoginSession,
  });

  final List<TagItem> initialTags;
  final Map<String, ChatConfig> initialConfigs;
  final String? initialActiveVendor;
  final List<VendorProfile> initialVendors;
  final List<Conversation> initialConversations;
  final int initialNextConvId;
  final int initialNextMsgId;
  final bool hasLoginSession;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState.initial(
        tags: initialTags,
        vendorProfiles: initialVendors,
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
        home: hasLoginSession ? const MainShellPage() : const LoginPage(),
      ),
    );
  }
}
