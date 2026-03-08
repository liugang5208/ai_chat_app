import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/chat_config.dart';

class ModelProviderPage extends StatefulWidget {
  const ModelProviderPage({super.key});

  @override
  State<ModelProviderPage> createState() => _ModelProviderPageState();
}

class _ModelProviderPageState extends State<ModelProviderPage> {
  static const List<String> _vendors = <String>['OpenAI', 'DeepSeek', 'Custom'];

  static const Map<String, String> _defaultBaseUrl = <String, String>{
    'OpenAI': 'https://api.openai.com/v1',
    'DeepSeek': 'https://api.deepseek.com',
  };

  static const Map<String, String> _defaultModel = <String, String>{
    'OpenAI': 'gpt-3.5-turbo',
    'DeepSeek': 'deepseek-chat',
  };

  String _selectedVendor = 'OpenAI';
  final TextEditingController _apiKeyCtrl = TextEditingController();
  final TextEditingController _baseUrlCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVendor(_selectedVendor));
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _loadVendor(String vendor) {
    final AppState app = AppStateScope.of(context);
    final ChatConfig? config = app.modelConfigs[vendor];
    if (config != null) {
      _apiKeyCtrl.text = config.apiKey;
      _baseUrlCtrl.text = config.baseUrl;
      _modelCtrl.text = config.model;
    } else {
      _apiKeyCtrl.clear();
      _baseUrlCtrl.text = _defaultBaseUrl[vendor] ?? '';
      _modelCtrl.text = _defaultModel[vendor] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('模型提供方', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Text(
            '模型提供商',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D2330)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedVendor,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _vendors
                .map((String v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                .toList(),
            onChanged: (String? val) {
              if (val == null) return;
              setState(() {
                _selectedVendor = val;
                _loadVendor(val);
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _baseUrlCtrl,
            decoration: InputDecoration(
              labelText: 'Base URL',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelCtrl,
            decoration: InputDecoration(
              labelText: 'Model Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final ChatConfig config = ChatConfig(
                vendor: _selectedVendor,
                apiKey: _apiKeyCtrl.text.trim(),
                baseUrl: _baseUrlCtrl.text.trim(),
                model: _modelCtrl.text.trim(),
              );
              app.saveModelConfig(config);
              app.setActiveVendor(_selectedVendor);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配置已保存')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C84FF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('保存并设置为当前使用', style: TextStyle(fontSize: 16)),
          ),
          if (app.modelConfigs.isNotEmpty) ...<Widget>[
            const SizedBox(height: 32),
            const Text(
              '已配置的提供方',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D2330)),
            ),
            const SizedBox(height: 8),
            ...app.modelConfigs.entries.map((MapEntry<String, ChatConfig> entry) {
              final bool isActive = app.activeVendor == entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEEF3FF) : const Color(0xFFF5F7FC),
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(color: const Color(0xFF4C84FF), width: 1.5)
                      : null,
                ),
                child: ListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    entry.value.model,
                    style: const TextStyle(color: Color(0xFF8A93A6)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isActive)
                        const Chip(
                          label: Text('使用中', style: TextStyle(fontSize: 12, color: Color(0xFF4C84FF))),
                          backgroundColor: Color(0xFFDDE8FF),
                          padding: EdgeInsets.zero,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFBFC4D0)),
                        onPressed: () => app.removeModelConfig(entry.key),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedVendor = _vendors.contains(entry.key) ? entry.key : 'Custom';
                      _loadVendor(entry.key);
                    });
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
