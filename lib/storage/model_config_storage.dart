import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/chat_config.dart';

class ModelConfigStorage {
  static Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/model_configs.json');
  }

  static Future<({Map<String, ChatConfig> configs, String? activeVendor})>
      load() async {
    try {
      final File file = await _file();
      if (!file.existsSync()) {
        return (configs: <String, ChatConfig>{}, activeVendor: null);
      }
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final Map<String, dynamic> raw =
          (data['configs'] as Map<String, dynamic>?) ?? {};
      final Map<String, ChatConfig> configs = raw.map(
        (String k, dynamic v) =>
            MapEntry(k, ChatConfig.fromJson(v as Map<String, dynamic>)),
      );
      return (
        configs: configs,
        activeVendor: data['activeVendor'] as String?,
      );
    } catch (_) {
      return (configs: <String, ChatConfig>{}, activeVendor: null);
    }
  }

  static Future<void> save(
    Map<String, ChatConfig> configs,
    String? activeVendor,
  ) async {
    final File file = await _file();
    await file.writeAsString(jsonEncode({
      'configs': configs.map((String k, ChatConfig v) => MapEntry(k, v.toJson())),
      'activeVendor': activeVendor,
    }));
  }
}
