import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/knowledge.dart';
import '../../models/tag_item.dart';

class FileListPage extends StatelessWidget {
  const FileListPage({
    super.key,
    required this.title,
    this.files,
    this.subdirectories,
  });

  final String title;
  final List<DocFile>? files;
  final List<TagItem>? subdirectories;

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<DocFile> list =
        files ??
        (app.knowledgeFolders.isNotEmpty
            ? app.knowledgeFolders.first.files
            : <DocFile>[]);
    final List<TagItem> tagDirs =
        subdirectories ??
        (app.knowledgeFolders.isNotEmpty
            ? app.knowledgeFolders.first.subdirectories
            : <TagItem>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: <Widget>[
          if (tagDirs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tagDirs
                    .map(
                      (TagItem tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tag.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E6676),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ...List<Widget>.generate(list.length, (int index) {
            final DocFile file = list[index];
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    file.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      Text(
                        file.preview,
                        style: const TextStyle(color: Color(0xFF8A93A6)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file.timeText,
                        style: const TextStyle(color: Color(0xFFB0B5C2)),
                      ),
                    ],
                  ),
                ),
                if (index != list.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
