class ChatConfig {
  ChatConfig({
    required this.vendor,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  });

  factory ChatConfig.fromJson(Map<String, dynamic> json) => ChatConfig(
        vendor: json['vendor'] as String,
        apiKey: json['apiKey'] as String,
        baseUrl: json['baseUrl'] as String,
        model: json['model'] as String,
      );

  final String vendor;
  final String apiKey;
  final String baseUrl;
  final String model;

  Map<String, dynamic> toJson() => {
        'vendor': vendor,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
      };
}
