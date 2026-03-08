import 'package:flutter/material.dart';
import '../../app_state.dart';

class TagEditPage extends StatefulWidget {
  const TagEditPage({
    super.key,
    required this.tagId,
    required this.initialName,
  });

  final String tagId;
  final String initialName;

  @override
  State<TagEditPage> createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '编辑',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F5)),
        ),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4C84FF),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('取消'),
        ),
        leadingWidth: 70,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final String value = _controller.text.trim();
              if (value.isNotEmpty) {
                AppStateScope.of(
                  context,
                ).updateTag(oldName: widget.initialName, newName: value);
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4C84FF),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/tag_edit_top_icon.png',
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 42),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7383),
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入标签名',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFC3C9D6),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FB),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    final String value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      AppStateScope.of(
                        context,
                      ).updateTag(oldName: widget.initialName, newName: value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
