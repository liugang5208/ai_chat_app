import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/knowledge.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({
    super.key,
    required this.title,
    required this.conversationId,
  });

  final String title;
  final int conversationId;

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  String? _activeDeleteTagKey;

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<DocFile> list = app
        .conversationKnowledgeFiles(widget.conversationId)
        .where((DocFile file) => file.tags.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _clearDeleteMode,
        child: list.isEmpty
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
                    onTap: () {
                      if (_activeDeleteTagKey != null) {
                        _clearDeleteMode();
                        return;
                      }
                      _showDetailDialog(context, file);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
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
                              ),
                            ],
                          ),
                          if (file.tags.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: file.tags.map((String tag) {
                                return _buildTagChip(
                                  app: app,
                                  file: file,
                                  tag: tag,
                                );
                              }).toList(),
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
      ),
    );
  }

  Widget _buildTagChip({
    required AppState app,
    required DocFile file,
    required String tag,
  }) {
    final String tagKey = _tagKey(file.messageId, tag);
    final bool showDelete = _activeDeleteTagKey == tagKey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _clearDeleteMode,
      onLongPress: () {
        setState(() {
          _activeDeleteTagKey = tagKey;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C84FF),
              ),
            ),
          ),
          if (showDelete)
            Positioned(
              right: -5,
              top: -5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _removeTag(app, file, tag),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0574F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 11, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _tagKey(int messageId, String tag) => '$messageId::$tag';

  void _clearDeleteMode() {
    if (_activeDeleteTagKey == null) return;
    setState(() {
      _activeDeleteTagKey = null;
    });
  }

  void _removeTag(AppState app, DocFile file, String tag) {
    app.removeTagsFromKnowledgeMessage(
      conversationId: widget.conversationId,
      messageId: file.messageId,
      tagNames: <String>[tag],
    );
    if (!mounted) return;
    setState(() {
      _activeDeleteTagKey = null;
    });
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
