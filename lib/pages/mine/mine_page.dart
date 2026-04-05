import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../config/app_branding.dart';
import 'my_favorites_page.dart';
import 'model_provider_page.dart';
import '../login_page.dart';
import '../../storage/local_auth_storage.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  Future<bool> _showDeleteAccountFirstConfirm(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('申请注销账户'),
          content: const Text('注销后将删除当前账号信息并退出登录。为避免误操作，请在下一步再次确认。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('继续'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<bool> _showDeleteAccountSecondConfirm(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认注销后果'),
          content: const Text(
            '注销后将发生以下后果：\n'
            '1. 当前手机号账户将从本机移除，无法恢复。\n'
            '2. 聊天记录、收藏、标签、模型配置将被清空。\n'
            '3. 你将立即退出登录。\n\n'
            '请确认你已知晓以上风险。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('我再想想'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE0574F),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认注销'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool firstConfirmed = await _showDeleteAccountFirstConfirm(context);
    if (!firstConfirmed || !context.mounted) return;
    final bool secondConfirmed = await _showDeleteAccountSecondConfirm(context);
    if (!secondConfirmed || !context.mounted) return;

    final AppState app = AppStateScope.of(context);
    await LocalAuthStorage.deleteCurrentAccountAndLocalData();
    await app.reloadAllFromStorage();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: Color(0xFF1F2430),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/mine_user_avatar.png',
              width: 140,
              height: 140,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppBranding.appName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2330),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(height: 1, color: Color(0xFFF5F6F8)),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyFavoritesPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/mine_favorite_icon.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '我的收藏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2330),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFC4D0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ModelProviderPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_outlined,
                      color: Color(0xFF4C84FF),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '模型提供方',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2330),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFC4D0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          InkWell(
            onTap: () async {
              await LocalAuthStorage.clearLoginSession();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE0574F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2330),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFC4D0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          InkWell(
            onTap: () => _deleteAccount(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_remove_alt_1_rounded,
                      color: Color(0xFFE0574F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '账户注销',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2330),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFC4D0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
        ],
      ),
    );
  }
}
