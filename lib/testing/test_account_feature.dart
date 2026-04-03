import '../app_state.dart';
import '../models/chat_config.dart';
import '../models/vendor_profile.dart';

class TestAccountFeature {
  static const bool enabled = true;

  static const String phone = '13241900943';
  static const String password = 'lgsky@0943';

  static const String qwenVendorName = '千问';
  static const String qwenBaseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1';
  static const String qwenApiKey = 'sk-35905cfe1bec428d86e3e0ca56d38756';
  static const List<String> qwenModels = <String>[
    'qwen-plus',
    'qwen-turbo',
    'qwen-max',
  ];

  static bool isTestPhone(String input) {
    if (!enabled) return false;
    return input.trim() == phone;
  }

  static bool canDirectLogin({
    required String phoneInput,
    required String passwordInput,
  }) {
    if (!enabled) return false;
    return phoneInput.trim() == phone && passwordInput == password;
  }

  static bool treatAsRegistered(String input) => isTestPhone(input);

  static VendorProfile qwenVendorProfile() {
    return const VendorProfile(
      name: qwenVendorName,
      iconKey: 'psychology',
      iconBgValue: 4286272244,
      iconColorValue: 4294967295,
      subtitle: 'Qwen API',
      defaultBaseUrl: qwenBaseUrl,
      defaultModels: qwenModels,
    );
  }

  static ChatConfig qwenConfig() {
    return ChatConfig(
      vendor: qwenVendorName,
      apiKey: qwenApiKey,
      baseUrl: qwenBaseUrl,
      model: qwenModels.first,
      selectedModel: qwenModels.first,
      models: qwenModels,
    );
  }

  static ({
    Map<String, ChatConfig> configs,
    String? activeVendor,
    List<VendorProfile> vendors,
  })
  applyPresetForLoginPhone({
    required String? loginPhone,
    required Map<String, ChatConfig> configs,
    required String? activeVendor,
    required List<VendorProfile> vendors,
  }) {
    if (!isTestPhone(loginPhone ?? '')) {
      return (
        configs: Map<String, ChatConfig>.from(configs),
        activeVendor: activeVendor,
        vendors: List<VendorProfile>.from(vendors),
      );
    }

    final Map<String, ChatConfig> nextConfigs = Map<String, ChatConfig>.from(
      configs,
    );
    final List<VendorProfile> nextVendors = List<VendorProfile>.from(vendors);
    if (!nextVendors.any((VendorProfile v) => v.name == qwenVendorName)) {
      nextVendors.insert(0, qwenVendorProfile());
    }
    nextConfigs[qwenVendorName] = qwenConfig();
    return (
      configs: nextConfigs,
      activeVendor: qwenVendorName,
      vendors: nextVendors,
    );
  }

  static void applyPresetToAppState(AppState app) {
    if (!enabled) return;
    if (!app.vendorProfiles.any(
      (VendorProfile v) => v.name == qwenVendorName,
    )) {
      app.addVendorProfile(qwenVendorProfile());
    }
    app.saveModelConfig(qwenConfig());
    app.setActiveVendor(qwenVendorName);
  }
}
