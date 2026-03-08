import 'package:flutter/material.dart';
import 'chat/home_page.dart';
import 'knowledge/knowledge_page.dart';
import 'mine/mine_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomePage(),
      const KnowledgePage(),
      const MinePage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        height: 84,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F1F5), width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(0, '首页', 'assets/main_bottom_home_icon.png'),
            _buildNavItem(1, '知识库', 'assets/main_bottom_knowledge_icon.png'),
            _buildNavItem(2, '我的', 'assets/main_bottom_mine_icon.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String assetPath) {
    final bool isSelected = _index == index;
    final Color color = isSelected
        ? const Color(0xFF1D2330)
        : const Color(0xFFBFC4D0);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              assetPath,
              width: 28,
              height: 28,
              // Removed color filter to ensure original icon is visible if color filter fails
              // Or use color only if the icons are monochrome
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
