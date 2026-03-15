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

  Future<void> _showEditModelDialog([String? initialModel]) async {
    _newModelCtrl.text = initialModel ?? '';
    final TextEditingController displayNameCtrl = TextEditingController();
    final TextEditingController contextWindowCtrl = TextEditingController();
    final TextEditingController maxOutputCtrl = TextEditingController();
    if (initialModel != null) {
      contextWindowCtrl.text = '128000';
      maxOutputCtrl.text = '4096';
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    initialModel == null ? '新建模型' : '编辑模型',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRowField(
                    label: '模型ID',
                    child: _buildDialogField(
                      controller: _newModelCtrl,
                      hintText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRowField(
                    label: '显示名称',
                    child: _buildDialogField(
                      controller: displayNameCtrl,
                      hintText: '可选',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '高级设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildColumnField(
                          label: '上下文窗口',
                          child: _buildDialogField(
                            controller: contextWindowCtrl,
                            hintText: '例如 128000',
                            showArrows: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildColumnField(
                          label: '最大输出Token数',
                          child: _buildDialogField(
                            controller: maxOutputCtrl,
                            hintText: '例如 4096',
                            showArrows: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final String name = _newModelCtrl.text.trim();
                        if (name.isEmpty) return;
                        setState(() {
                          if (initialModel != null) {
                            final int index = _models.indexOf(initialModel);
                            if (index != -1) {
                              _models[index] = name;
                            }
                          } else {
                            if (!_models.contains(name)) _models.insert(0, name);
                          }
                          _selectedModel = name;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2F8DFB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildRowField({required String label, required Widget child}) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildColumnField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _dialogInputDecoration({String? hintText, bool showArrows = false}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2F8DFB), width: 1),
      ),
      suffixIcon: showArrows
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.keyboard_arrow_up, size: 14, color: Color(0xFF9CA3AF)),
                Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF9CA3AF)),
              ],
            )
          : null,
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String hintText,
    bool showArrows = false,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        decoration: _dialogInputDecoration(hintText: hintText, showArrows: showArrows),
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      ),
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

  void _persistModelsToConfig() {
    final AppState app = AppStateScope.of(context);
    final ChatConfig? existing = app.modelConfigs[widget.vendorName];
    final List<String> normalizedModels = _models
        .map((String m) => m.trim())
        .where((String m) => m.isNotEmpty)
        .toSet()
        .toList();
    final String selected = (_selectedModel ?? '').trim();
    final String effectiveModel = selected.isNotEmpty
        ? selected
        : (normalizedModels.isNotEmpty ? normalizedModels.first : '');

    app.saveModelConfig(
      ChatConfig(
        vendor: widget.vendorName,
        apiKey: _apiKeyCtrl.text.trim().isNotEmpty
            ? _apiKeyCtrl.text.trim()
            : (existing?.apiKey ?? ''),
        baseUrl: _baseUrlCtrl.text.trim().isNotEmpty
            ? _baseUrlCtrl.text.trim()
            : (existing?.baseUrl ?? ''),
        model: effectiveModel,
        selectedModel: effectiveModel,
        models: normalizedModels,
      ),
    );
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
              _ActionChip(label: '+新建', onTap: () => _showEditModelDialog()),
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
                          onPressed: () => _showEditModelDialog(model),
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
                            _persistModelsToConfig();
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
