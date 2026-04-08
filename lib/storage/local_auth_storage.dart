import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../testing/test_account_feature.dart';

class LocalAuthUser {
  LocalAuthUser({
    required this.phone,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  final String phone;
  final String passwordHash;
  final String salt;
  final String createdAt;

  factory LocalAuthUser.fromJson(Map<String, dynamic> json) {
    return LocalAuthUser(
      phone: json['phone'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      salt: json['salt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phone,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': createdAt,
    };
  }
}

class LocalAuthStorage {
  static final Random _random = Random.secure();
  static const String guestSessionPhone = '__guest__';

  static Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/auth_users.json');
  }

  static Future<File> _sessionFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/auth_session.json');
  }

  static Future<File> _testAccountStateFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/test_account_state.json');
  }

  static Future<bool> _isBuiltInTestAccountDisabled() async {
    try {
      final File file = await _testAccountStateFile();
      if (!file.existsSync()) return false;
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return (data['disabled'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _setBuiltInTestAccountDisabled(bool disabled) async {
    try {
      final File file = await _testAccountStateFile();
      await file.writeAsString(
        jsonEncode(<String, dynamic>{
          'disabled': disabled,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  static Future<bool> shouldApplyTestAccountPreset(String phone) async {
    final String normalized = phone.trim();
    if (isGuestPhone(normalized)) return false;
    if (!TestAccountFeature.isTestPhone(normalized)) return false;
    return !(await _isBuiltInTestAccountDisabled());
  }

  static Future<List<LocalAuthUser>> loadUsers() async {
    try {
      final File file = await _file();
      if (!file.existsSync()) return <LocalAuthUser>[];
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final List<dynamic> users =
          (data['users'] as List<dynamic>?) ?? <dynamic>[];
      return users
          .map((dynamic e) => LocalAuthUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <LocalAuthUser>[];
    }
  }

  static Future<void> _saveUsers(List<LocalAuthUser> users) async {
    final File file = await _file();
    await file.writeAsString(
      jsonEncode(<String, dynamic>{
        'users': users.map((LocalAuthUser u) => u.toJson()).toList(),
      }),
    );
  }

  static Future<bool> registerUser({
    required String phone,
    required String password,
  }) async {
    final String normalized = phone.trim();
    if (await shouldApplyTestAccountPreset(normalized)) return false;
    final List<LocalAuthUser> users = await loadUsers();
    final bool exists = users.any((LocalAuthUser u) => u.phone == normalized);
    if (exists) return false;
    final String salt = _randomSalt();
    final String hash = _hashPassword(password, salt);
    users.add(
      LocalAuthUser(
        phone: normalized,
        passwordHash: hash,
        salt: salt,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    await _saveUsers(users);
    if (TestAccountFeature.isTestPhone(normalized)) {
      await _setBuiltInTestAccountDisabled(true);
    }
    return true;
  }

  static Future<bool> verifyPassword({
    required String phone,
    required String password,
  }) async {
    final String normalized = phone.trim();
    if (await shouldApplyTestAccountPreset(normalized) &&
        TestAccountFeature.canDirectLogin(
          phoneInput: normalized,
          passwordInput: password,
        )) {
      return true;
    }
    final List<LocalAuthUser> users = await loadUsers();
    final LocalAuthUser? user = _findByPhone(users, normalized);
    if (user == null) return false;
    final String hash = _hashPassword(password, user.salt);
    return hash == user.passwordHash;
  }

  static Future<bool> userExists(String phone) async {
    final String normalized = phone.trim();
    if (await shouldApplyTestAccountPreset(normalized)) return true;
    final List<LocalAuthUser> users = await loadUsers();
    return _findByPhone(users, normalized) != null;
  }

  static Future<bool> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    final String normalized = phone.trim();
    final List<LocalAuthUser> users = await loadUsers();
    final int idx = users.indexWhere(
      (LocalAuthUser u) => u.phone == normalized,
    );
    if (idx < 0) return false;
    final String salt = _randomSalt();
    users[idx] = LocalAuthUser(
      phone: users[idx].phone,
      passwordHash: _hashPassword(newPassword, salt),
      salt: salt,
      createdAt: users[idx].createdAt,
    );
    await _saveUsers(users);
    return true;
  }

  static LocalAuthUser? _findByPhone(List<LocalAuthUser> users, String phone) {
    for (final LocalAuthUser u in users) {
      if (u.phone == phone) return u;
    }
    return null;
  }

  static String _randomSalt() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hashPassword(String password, String salt) {
    final List<int> bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  static Future<void> saveLoginSession(String phone) async {
    final File file = await _sessionFile();
    await file.writeAsString(
      jsonEncode(<String, dynamic>{
        'phone': phone.trim(),
        'loggedInAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  static Future<void> saveGuestSession() async {
    await saveLoginSession(guestSessionPhone);
  }

  static bool isGuestPhone(String phone) {
    return phone.trim() == guestSessionPhone;
  }

  static Future<String?> loadLoginPhone() async {
    try {
      final File file = await _sessionFile();
      if (!file.existsSync()) return null;
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final String phone = (data['phone'] as String? ?? '').trim();
      if (phone.isEmpty) return null;
      if (isGuestPhone(phone)) return phone;
      final bool exists = await userExists(phone);
      if (!exists) return null;
      return phone;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearLoginSession() async {
    try {
      final File file = await _sessionFile();
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<bool> deleteUserByPhone(String phone) async {
    final String normalized = phone.trim();
    if (normalized.isEmpty) return false;

    final bool isTestPhone = TestAccountFeature.isTestPhone(normalized);
    if (isTestPhone) {
      await _setBuiltInTestAccountDisabled(true);
    }

    final List<LocalAuthUser> users = await loadUsers();
    final int index = users.indexWhere(
      (LocalAuthUser user) => user.phone == normalized,
    );
    if (index >= 0) {
      users.removeAt(index);
      await _saveUsers(users);
      return true;
    }
    return isTestPhone;
  }

  static Future<void> _deleteDataFile(String fileName) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/$fileName');
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<bool> deleteCurrentAccountAndLocalData() async {
    final String? phone = await loadLoginPhone();
    bool deleted = false;
    if (phone != null) {
      deleted = await deleteUserByPhone(phone);
    }

    await clearLoginSession();
    await _deleteDataFile('conversations.json');
    await _deleteDataFile('tags.json');
    await _deleteDataFile('model_configs.json');

    return deleted;
  }
}
