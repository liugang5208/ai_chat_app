import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/tag_item.dart';
import 'tag_edit_page.dart';
import 'tag_insert_page.dart';

class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  String? _selectedTagId;

  Future<void> _showHalfCard(BuildContext context, Widget child) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.62,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _showHalfCard(context, const TagInsertPage());
              setState(() {});
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: app.tags.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (_, int index) {
              final TagItem tag = app.tags[index];
              final bool selected = _selectedTagId == tag.id;
              return GestureDetector(
                onLongPress: () => setState(() => _selectedTagId = tag.id),
                onTap: () => setState(() => _selectedTagId = null),
                child: Container(
                  decoration: BoxDecoration(
                    color: tag.color,
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(color: const Color(0xFF4C84FF), width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Color(0xFF4C84FF),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_selectedTagId != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEFF2F7))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () async {
                        final TagItem tag = app.tags.firstWhere(
                          (TagItem t) => t.id == _selectedTagId,
                        );
                        await _showHalfCard(
                          context,
                          TagEditPage(tagId: tag.id, initialName: tag.name),
                        );
                        setState(() => _selectedTagId = null);
                      },
                      icon: const Icon(Icons.edit_note),
                      label: const Text('编辑'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        app.deleteTag(_selectedTagId!);
                        setState(() => _selectedTagId = null);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('删除'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
