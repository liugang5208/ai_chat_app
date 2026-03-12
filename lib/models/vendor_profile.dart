import 'package:flutter/material.dart';

class VendorProfile {
  const VendorProfile({
    required this.name,
    required this.iconKey,
    required this.iconBgValue,
    required this.iconColorValue,
    required this.subtitle,
    required this.defaultBaseUrl,
    required this.defaultModels,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) => VendorProfile(
    name: (json['name'] as String? ?? '').trim(),
    iconKey: (json['iconKey'] as String? ?? 'extension').trim(),
    iconBgValue: (json['iconBgValue'] as int?) ?? 0xFF767B87,
    iconColorValue: (json['iconColorValue'] as int?) ?? 0xFFFFFFFF,
    subtitle: (json['subtitle'] as String? ?? '').trim(),
    defaultBaseUrl: (json['defaultBaseUrl'] as String? ?? '').trim(),
    defaultModels:
        ((json['defaultModels'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => e.toString().trim())
            .where((String e) => e.isNotEmpty)
            .toList(),
  );

  final String name;
  final String iconKey;
  final int iconBgValue;
  final int iconColorValue;
  final String subtitle;
  final String defaultBaseUrl;
  final List<String> defaultModels;

  Color get iconBg => Color(iconBgValue);
  Color get iconColor => Color(iconColorValue);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'iconKey': iconKey,
    'iconBgValue': iconBgValue,
    'iconColorValue': iconColorValue,
    'subtitle': subtitle,
    'defaultBaseUrl': defaultBaseUrl,
    'defaultModels': defaultModels,
  };
}
