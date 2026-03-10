import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/conversation.dart';
import '../chat/chat_page.dart';

class FilePreviewPage extends StatefulWidget {
  const FilePreviewPage({super.key});

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<Conversation> filtered =
        app.conversations
            .where(
              (Conversation c) =>
                  _query.isEmpty ||
                  c.title.toLowerCase().contains(_query.trim().toLowerCase()),
            )
            .toList()
          ..sort(
            (Conversation a, Conversation b) =>
                b.updatedAt.compareTo(a.updatedAt),
          );

    final Map<String, List<Conversation>> grouped = _groupByTime(filtered);
    final List<String> orderedSections = <String>[
      '今天',
      '昨天',
      '近7天',
      '近30天',
      '更早',
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '文件预览',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 10),
            child: SizedBox(
              height: 44,
              child: TextField(
                onChanged: (String value) => setState(() => _query = value),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1D2330),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '查找聊天内容',
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
                  fillColor: const Color(0xFFF2F4F8),
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              children: orderedSections
                  .where(
                    (String section) =>
                        (grouped[section] ?? <Conversation>[]).isNotEmpty,
                  )
                  .map((String section) {
                    final List<Conversation> items = grouped[section]!;
                    return _buildSection(context, section, items);
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Conversation> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA7ACB8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((Conversation item) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatPage(conversationId: item.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E2430),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, List<Conversation>> _groupByTime(List<Conversation> items) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final Map<String, List<Conversation>> result = <String, List<Conversation>>{
      '今天': <Conversation>[],
      '昨天': <Conversation>[],
      '近7天': <Conversation>[],
      '近30天': <Conversation>[],
      '更早': <Conversation>[],
    };

    for (final Conversation c in items) {
      final DateTime date = DateTime(
        c.updatedAt.year,
        c.updatedAt.month,
        c.updatedAt.day,
      );
      final int diffDays = today.difference(date).inDays;
      if (diffDays <= 0) {
        result['今天']!.add(c);
      } else if (diffDays == 1) {
        result['昨天']!.add(c);
      } else if (diffDays <= 6) {
        result['近7天']!.add(c);
      } else if (diffDays <= 29) {
        result['近30天']!.add(c);
      } else {
        result['更早']!.add(c);
      }
    }
    return result;
  }
}
