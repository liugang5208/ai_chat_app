class ChatConfig {
  ChatConfig({
    required this.vendor,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    List<String>? models,
    String? selectedModel,
  }) : models = models ?? <String>[model],
       selectedModel = selectedModel ?? model;

  factory ChatConfig.fromJson(Map<String, dynamic> json) => ChatConfig(
    vendor: json['vendor'] as String,
    apiKey: json['apiKey'] as String,
    baseUrl: json['baseUrl'] as String,
    model: json['model'] as String? ?? '',
    models: ((json['models'] as List<dynamic>?) ?? const <dynamic>[])
        .map((dynamic e) => e.toString())
        .where((String e) => e.trim().isNotEmpty)
        .toList(),
    selectedModel: json['selectedModel'] as String?,
  );

  final String vendor;
  final String apiKey;
  final String baseUrl;
  // Backward compatible field for historical data.
  final String model;
  final List<String> models;
  final String selectedModel;

  String get effectiveModel {
    if (selectedModel.trim().isNotEmpty) return selectedModel.trim();
    if (models.isNotEmpty) return models.first;
    return model;
  }

  Map<String, dynamic> toJson() => {
    'vendor': vendor,
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    'model': effectiveModel,
    'models': models,
    'selectedModel': effectiveModel,
  };

  ChatConfig copyWith({
    String? vendor,
    String? apiKey,
    String? baseUrl,
    String? model,
    List<String>? models,
    String? selectedModel,
  }) {
    return ChatConfig(
      vendor: vendor ?? this.vendor,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? effectiveModel,
      models: models ?? this.models,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}
