import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_config.dart';
import '../models/vendor_profile.dart';

class ModelConfigStorage {
  static Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/model_configs.json');
  }

  static Future<List<VendorProfile>> _loadSeedVendors() async {
    try {
      final String raw = await rootBundle.loadString(
        'assets/model_vendors_seed.json',
      );
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((dynamic e) => VendorProfile.fromJson(e as Map<String, dynamic>))
          .where((VendorProfile v) => v.name.isNotEmpty)
          .toList();
    } catch (_) {
      return <VendorProfile>[];
    }
  }

  static Future<
    ({
      Map<String, ChatConfig> configs,
      String? activeVendor,
      List<VendorProfile> vendors,
    })
  >
  load() async {
    try {
      final File file = await _file();
      final List<VendorProfile> seedVendors = await _loadSeedVendors();
      if (!file.existsSync()) {
        await save(<String, ChatConfig>{}, null, seedVendors);
        return (
          configs: <String, ChatConfig>{},
          activeVendor: null,
          vendors: seedVendors,
        );
      }
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final Map<String, dynamic> raw =
          (data['configs'] as Map<String, dynamic>?) ?? {};
      final Map<String, ChatConfig> configs = raw.map(
        (String k, dynamic v) =>
            MapEntry(k, ChatConfig.fromJson(v as Map<String, dynamic>)),
      );
      final List<VendorProfile> vendors =
          ((data['vendors'] as List<dynamic>?) ?? const <dynamic>[])
              .map(
                (dynamic e) =>
                    VendorProfile.fromJson(e as Map<String, dynamic>),
              )
              .where((VendorProfile v) => v.name.isNotEmpty)
              .toList();
      if (vendors.isEmpty && seedVendors.isNotEmpty) {
        await save(configs, data['activeVendor'] as String?, seedVendors);
      }
      return (
        configs: configs,
        activeVendor: data['activeVendor'] as String?,
        vendors: vendors.isNotEmpty ? vendors : seedVendors,
      );
    } catch (_) {
      return (
        configs: <String, ChatConfig>{},
        activeVendor: null,
        vendors: await _loadSeedVendors(),
      );
    }
  }

  static Future<void> save(
    Map<String, ChatConfig> configs,
    String? activeVendor,
    List<VendorProfile> vendors,
  ) async {
    final File file = await _file();
    await file.writeAsString(
      jsonEncode({
        'configs': configs.map(
          (String k, ChatConfig v) => MapEntry(k, v.toJson()),
        ),
        'activeVendor': activeVendor,
        'vendors': vendors.map((VendorProfile v) => v.toJson()).toList(),
      }),
    );
  }
}
