import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/knowledge.dart';

class FileListPage extends StatelessWidget {
  const FileListPage({
    super.key,
    required this.title,
    required this.conversationId,
  });

  final String title;
  final int conversationId;

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<DocFile> list = app.conversationKnowledgeFiles(conversationId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
      ),
      body: list.isEmpty
          ? const Center(
              child: Text(
                '暂无收录内容',
                style: TextStyle(
                  color: Color(0xFF9FA6B6),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1, color: Color(0xFFF2F3F6)),
              itemBuilder: (BuildContext context, int index) {
                final DocFile file = list[index];
                return InkWell(
                  onTap: () => _showDetailDialog(context, file),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          file.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 1.2,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        if (file.tagName != null &&
                            file.tagName!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              file.tagName!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4C84FF),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          file.preview,
                          style: const TextStyle(
                            color: Color(0xFF8D95A6),
                            fontSize: 15,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          file.timeText,
                          style: const TextStyle(
                            color: Color(0xFFB3B8C5),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showDetailDialog(BuildContext context, DocFile file) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  file.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      file.detail ?? file.preview,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF4E5667),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
