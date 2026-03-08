import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/tag_item.dart';

class TagStorage {
  static const List<Map<String, dynamic>> _defaults = <Map<String, dynamic>>[
    {'id': '学习', 'name': '学习', 'color': 0xFFF0F2FF},
    {'id': '工作', 'name': '工作', 'color': 0xFFEEF9F1},
    {'id': '旅游', 'name': '旅游', 'color': 0xFFFAFAEB},
    {'id': '其他', 'name': '其他', 'color': 0xFFEEF7FF},
    {'id': '生活', 'name': '生活', 'color': 0xFFEFFAF6},
    {'id': '阅读', 'name': '阅读', 'color': 0xFFF0FAFF},
  ];

  static Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tags.json');
  }

  static Future<List<TagItem>> load() async {
    try {
      final File file = await _file();
      if (!file.existsSync()) {
        final List<TagItem> defaults = _defaults
            .map((Map<String, dynamic> e) => TagItem.fromJson(e))
            .toList();
        await save(defaults);
        return defaults;
      }
      final List<dynamic> list =
          jsonDecode(await file.readAsString()) as List<dynamic>;
      return list
          .map((dynamic e) => TagItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaults.map((Map<String, dynamic> e) => TagItem.fromJson(e)).toList();
    }
  }

  static Future<void> save(List<TagItem> tags) async {
    final File file = await _file();
    await file.writeAsString(
      jsonEncode(tags.map((TagItem t) => t.toJson()).toList()),
    );
  }
}
