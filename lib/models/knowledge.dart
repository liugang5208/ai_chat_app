import '../models/tag_item.dart';

class KnowledgeFolder {
  KnowledgeFolder({
    required this.name,
    required this.files,
    required this.subdirectories,
  });

  final String name;
  final List<DocFile> files;
  final List<TagItem> subdirectories;
}

class DocFile {
  DocFile({
    required this.messageId,
    required this.title,
    required this.preview,
    required this.timeText,
    List<String>? tags,
    this.detail,
    this.createdAt,
    this.tagName,
  }) : tags = tags ?? <String>[];

  final int messageId;
  final String title;
  final String preview;
  final String timeText;
  final List<String> tags;
  final String? detail;
  final DateTime? createdAt;
  final String? tagName;
}
