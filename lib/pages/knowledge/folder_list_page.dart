import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/tag_item.dart';
import '../../models/knowledge.dart';
import 'file_list_page.dart';

class FolderListPage extends StatelessWidget {
  const FolderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<TagItem> tagDirs = app.tags;
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件夹'),
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
          Expanded(
            child: ListView.separated(
              itemCount: tagDirs.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    color: Color(0xFFF5F6F8),
                    indent: 84,
                  ),
              itemBuilder: (BuildContext context, int index) {
                final TagItem tagDir = tagDirs[index];
                final KnowledgeFolder? ownerFolder = app.knowledgeFolders
                    .cast<KnowledgeFolder?>()
                    .firstWhere(
                      (KnowledgeFolder? folder) =>
                          folder != null &&
                          folder.subdirectories.any(
                            (TagItem t) => t.name == tagDir.name,
                          ),
                      orElse: () => null,
                    );
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FileListPage(
                          title: tagDir.name,
                          files: ownerFolder?.files,
                          subdirectories: <TagItem>[tagDir],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/knowledge_folder_icon.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            tagDir.name,
                            style: const TextStyle(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
