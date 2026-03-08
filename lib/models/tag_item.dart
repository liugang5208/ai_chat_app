import 'package:flutter/material.dart';

class TagItem {
  TagItem({required this.id, required this.name, required this.color});

  factory TagItem.fromJson(Map<String, dynamic> json) => TagItem(
        id: json['id'] as String,
        name: json['name'] as String,
        color: Color(json['color'] as int),
      );

  String id;
  String name;
  final Color color;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };
}
