import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/conversation.dart';
import 'file_list_page.dart';

class FolderListPage extends StatefulWidget {
  const FolderListPage({super.key});

  @override
  State<FolderListPage> createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final String q = _query.trim().toLowerCase();
    final List<Conversation> subDirs = app.conversationsSorted().where((
      Conversation item,
    ) {
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q);
    }).toList();
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
                onChanged: (String value) => setState(() => _query = value),
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
              itemCount: subDirs.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    color: Color(0xFFF5F6F8),
                    indent: 84,
                  ),
              itemBuilder: (BuildContext context, int index) {
                final Conversation subDir = subDirs[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FileListPage(
                          title: subDir.title,
                          conversationId: subDir.id,
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
                            subDir.title,
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
