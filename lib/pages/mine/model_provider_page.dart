import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/chat_config.dart';
import '../../models/vendor_profile.dart';
import 'model_provider_config_page.dart';
import 'model_provider_data.dart';

class ModelProviderPage extends StatefulWidget {
  const ModelProviderPage({super.key});

  @override
  State<ModelProviderPage> createState() => _ModelProviderPageState();
}

class _ModelProviderPageState extends State<ModelProviderPage> {
  Future<void> _openConfig(String vendorName) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModelProviderConfigPage(vendorName: vendorName),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showAddVendorDialog() async {
    final TextEditingController ctrl = TextEditingController();
    final String? newVendorName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加厂商'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: '输入厂商名称',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final String name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.of(context).pop(name);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
    if (!mounted || newVendorName == null || newVendorName.trim().isEmpty) {
      return;
    }
    final AppState app = AppStateScope.of(context);
    final String vendorName = newVendorName.trim();
    if (!app.vendorProfiles.any((VendorProfile v) => v.name == vendorName)) {
      app.addVendorProfile(
        VendorProfile(
          name: vendorName,
          iconKey: 'extension',
          iconBgValue: 0xFF767B87,
          iconColorValue: 0xFFFFFFFF,
          subtitle: 'Custom Provider',
          defaultBaseUrl: '',
          defaultModels: <String>[],
        ),
      );
    }
    await _openConfig(vendorName);
  }

  List<String> _buildVendorOrder(
    AppState app,
    Map<String, ChatConfig> configs,
  ) {
    final List<String> names = app.vendorProfiles
        .map((VendorProfile e) => e.name)
        .toList();
    for (final String key in configs.keys) {
      if (!names.contains(key)) names.add(key);
    }
    return names;
  }

  VendorProfile _vendorByName(AppState app, String name) {
    return app.vendorByName(name) ??
        const VendorProfile(
          name: 'Custom',
          iconKey: 'extension',
          iconBgValue: 0xFF767B87,
          iconColorValue: 0xFFFFFFFF,
          subtitle: 'Custom Provider',
          defaultBaseUrl: '',
          defaultModels: <String>[],
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<String> names = _buildVendorOrder(app, app.modelConfigs);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F9),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('设置'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 6),
              itemCount: names.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1, color: Color(0xFFE8E9ED)),
              itemBuilder: (BuildContext context, int index) {
                final String name = names[index];
                final VendorProfile vendor = _vendorByName(app, name);
                final bool active = app.activeVendor == name;
                return InkWell(
                  onTap: () => _openConfig(name),
                  child: SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: vendor.iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ModelProviderData.iconForKey(vendor.iconKey),
                              color: vendor.iconColor,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24 / 1.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2E3440),
                              ),
                            ),
                          ),
                          if (active)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C58B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFA1A7B3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _showAddVendorDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4EA1E8), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    foregroundColor: const Color(0xFF2A8EDB),
                    textStyle: const TextStyle(
                      fontSize: 21 / 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('+  添加'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
