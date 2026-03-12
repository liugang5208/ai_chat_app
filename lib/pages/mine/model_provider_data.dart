import 'package:flutter/material.dart';

class ModelProviderData {
  static IconData iconForKey(String key) {
    switch (key) {
      case 'smart_toy':
        return Icons.smart_toy_outlined;
      case 'token':
        return Icons.token;
      case 'psychology':
        return Icons.psychology_alt_outlined;
      case 'openai':
        return Icons.auto_awesome;
      case 'gemini':
        return Icons.stars;
      case 'claude':
        return Icons.sunny;
      case 'deepseek':
        return Icons.flutter_dash;
      case 'openrouter':
        return Icons.change_history;
      default:
        return Icons.extension;
    }
  }
}
