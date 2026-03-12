import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/chat_config.dart';
import '../../models/vendor_profile.dart';

class ModelProviderConfigPage extends StatefulWidget {
  const ModelProviderConfigPage({super.key, required this.vendorName});

  final String vendorName;

  @override
  State<ModelProviderConfigPage> createState() =>
      _ModelProviderConfigPageState();
}

class _ModelProviderConfigPageState extends State<ModelProviderConfigPage> {
  final TextEditingController _apiKeyCtrl = TextEditingController();
  final TextEditingController _baseUrlCtrl = TextEditingController();
  final TextEditingController _newModelCtrl = TextEditingController();
  bool _obscureApiKey = true;
  List<String> _models = <String>[];
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _newModelCtrl.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final AppState app = AppStateScope.of(context);
    final VendorProfile? vendor = app.vendorByName(widget.vendorName);
    final ChatConfig? config = app.modelConfigs[widget.vendorName];
    final List<String> defaults = List<String>.from(
      vendor?.defaultModels ?? <String>[],
    );

    if (config != null) {
      _apiKeyCtrl.text = config.apiKey;
      _baseUrlCtrl.text = config.baseUrl;
      _models = config.models.isNotEmpty
          ? List<String>.from(config.models)
          : defaults.where((String it) => it.isNotEmpty).toList();
      if (_models.isEmpty && config.model.isNotEmpty) {
        _models.add(config.model);
      }
      _selectedModel = config.effectiveModel.isNotEmpty
          ? config.effectiveModel
          : (_models.isNotEmpty ? _models.first : null);
    } else {
      _apiKeyCtrl.clear();
      _baseUrlCtrl.text = vendor?.defaultBaseUrl ?? '';
      _models = defaults.where((String it) => it.isNotEmpty).toList();
      _selectedModel = _models.isNotEmpty ? _models.first : null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveConfig() async {
    final AppState app = AppStateScope.of(context);
    final String apiKey = _apiKeyCtrl.text.trim();
    final String baseUrl = _baseUrlCtrl.text.trim();
    final String model = (_selectedModel ?? '').trim();
    final List<String> normalizedModels = _models
        .map((String m) => m.trim())
        .where((String m) => m.isNotEmpty)
        .toSet()
        .toList();

    if (apiKey.isEmpty || baseUrl.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请完整填写 API 密钥、API 主机和模型')));
      return;
    }
    final Uri? uri = Uri.tryParse(baseUrl);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API 主机格式不正确')));
      return;
    }
    if (!normalizedModels.contains(model)) {
      normalizedModels.insert(0, model);
    }

    app.saveModelConfig(
      ChatConfig(
        vendor: widget.vendorName,
        apiKey: apiKey,
        baseUrl: baseUrl,
        model: model,
        selectedModel: model,
        models: normalizedModels,
      ),
    );
    app.setActiveVendor(widget.vendorName);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('配置已保存并启用')));
  }

  void _onAddModel() {
    _newModelCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建模型'),
          content: TextField(
            controller: _newModelCtrl,
            decoration: const InputDecoration(
              hintText: '输入模型名称',
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
                final String name = _newModelCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  if (!_models.contains(name)) _models.insert(0, name);
                  _selectedModel = name;
                });
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _onReset() {
    final AppState app = AppStateScope.of(context);
    final VendorProfile? vendor = app.vendorByName(widget.vendorName);
    setState(() {
      _baseUrlCtrl.text = vendor?.defaultBaseUrl ?? '';
      _models = List<String>.from(
        vendor?.defaultModels ?? <String>[],
      ).where((String it) => it.isNotEmpty).toList();
      _selectedModel = _models.isNotEmpty ? _models.first : null;
    });
  }

  void _onFetchModels() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('示例页面：请按你的 API 实现获取模型列表')));
  }

  String _endpointPreview(String baseUrl) {
    final String normalized = baseUrl.trim().replaceAll(RegExp(r'\/+$'), '');
    if (normalized.isEmpty) return '';
    if (normalized.endsWith('/chat/completions')) return normalized;
    if (normalized.endsWith('/v1')) return '$normalized/chat/completions';
    return '$normalized/v1/chat/completions';
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final VendorProfile? vendor = app.vendorByName(widget.vendorName);
    final List<String> uiModels = _models;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F9),
        surfaceTintColor: Colors.transparent,
        title: const Text('设置'),
        centerTitle: true,
        actions: <Widget>[
          TextButton(onPressed: _saveConfig, child: const Text('保存')),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                widget.vendorName,
                style: const TextStyle(
                  fontSize: 42 / 1.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222831),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.open_in_new, size: 18, color: Color(0xFF9095A0)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            (vendor?.subtitle ?? '').isEmpty
                ? '经典 API 调用方式，适用于主流模型接入。'
                : vendor!.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'API 密钥',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _apiKeyCtrl,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureApiKey = !_obscureApiKey),
                        icon: Icon(
                          _obscureApiKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: const Color(0xFF9AA1AD),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                width: 72,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF7A818D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('检查'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'API 主机',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: TextField(
              controller: _baseUrlCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'https://api.openai.com',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _endpointPreview(_baseUrlCtrl.text),
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 18),
          const Text(
            '模型',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _ActionChip(label: '+  新建', onTap: _onAddModel),
              const SizedBox(width: 8),
              _ActionChip(label: '重置', onTap: _onReset),
              const SizedBox(width: 8),
              _ActionChip(label: '获取', onTap: _onFetchModels),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: uiModels.map((String model) {
                final bool isSelected = model == _selectedModel;
                return InkWell(
                  onTap: () => setState(() => _selectedModel = model),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF1F5FF)
                          : Colors.white,
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFF0F1F3)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                model,
                                style: const TextStyle(
                                  fontSize: 23 / 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '上下文 128K   输出 4K',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              setState(() => _selectedModel = model),
                          icon: Icon(
                            isSelected
                                ? Icons.settings
                                : Icons.settings_outlined,
                            color: const Color(0xFF7D8695),
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              uiModels.remove(model);
                              if (_selectedModel == model) {
                                _selectedModel = uiModels.isNotEmpty
                                    ? uiModels.first
                                    : null;
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Color(0xFFE35C64),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
