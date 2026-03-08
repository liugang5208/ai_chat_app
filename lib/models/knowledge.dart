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
  DocFile({required this.title, required this.preview, required this.timeText});

  final String title;
  final String preview;
  final String timeText;
}
