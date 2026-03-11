import 'package:flutter/material.dart';
import 'folder_list_page.dart';
import 'tag_list_page.dart';
import 'file_preview_page.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D2330),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              height: 44,
              child: TextField(
                style: const TextStyle(fontSize: 16, color: Color(0xFF1D2330)),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C9D5),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC4C9D5),
                    size: 22,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 22,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: const Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          _entryTile(
            assetPath: 'assets/knowledge_folder.png',
            title: '文件夹',
            bgColor: const Color(0xFFFFF7E8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FolderListPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          _entryTile(
            assetPath: 'assets/knowledge_tag.png',
            title: '标签',
            bgColor: const Color(0xFFE8F1FF),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TagListPage()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF5F6F8), indent: 84),
          _entryTile(
            assetPath: 'assets/knowledge_preview.png',
            title: '文件预览',
            bgColor: const Color(0xFFE8FFFB),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FilePreviewPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _entryTile({
    required String assetPath,
    required String title,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(assetPath, width: 28, height: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2330),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBFC4D0), size: 24),
          ],
        ),
      ),
    );
  }
}
