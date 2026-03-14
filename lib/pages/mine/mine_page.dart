import 'package:flutter/material.dart';
import 'my_favorites_page.dart';
import 'model_provider_page.dart';
import '../login_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

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
            '小智AI',
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
            onTap: () {
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
        ],
      ),
    );
  }
}
