import 'package:flutter/material.dart';

class TestDialog extends StatefulWidget {
  @override
  _TestDialogState createState() => _TestDialogState();
}

class _TestDialogState extends State<TestDialog> {
  bool _isMoreExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top Row (Like / Dislike)
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop('like'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: const [
                            Icon(Icons.thumb_up_outlined, size: 24, color: Color(0xFF666666)),
                            SizedBox(height: 4),
                            Text('喜欢', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop('dislike'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: const [
                            Icon(Icons.thumb_down_outlined, size: 24, color: Color(0xFF666666)),
                            SizedBox(height: 4),
                            Text('不喜欢', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // Main Actions
              _buildActionTile(icon: Icons.copy, title: '复制', action: 'copy'),
              _buildActionTile(icon: Icons.text_fields, title: '选取文字', action: 'select_text'),
              _buildActionTile(icon: Icons.volume_up_outlined, title: '朗读', action: 'read_aloud'),
              _buildActionTile(icon: Icons.note_add_outlined, title: '创建文档', action: 'create_doc'),

              // Expandable More Section
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _isMoreExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isMoreExpanded = expanded;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(Icons.more_horiz, size: 24, color: Color(0xFF1D1F24)),
                  title: const Text('更多', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1D1F24))),
                  trailing: Icon(
                    _isMoreExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF1D1F24),
                  ),
                  children: [
                    _buildActionTile(icon: Icons.reply, title: '追问', action: 'followup'),
                    _buildActionTile(icon: Icons.edit_square, title: '创建新对话', action: 'new_chat'),
                    _buildActionTile(icon: Icons.file_download_outlined, title: '导出文件', action: 'export'),
                    _buildActionTile(icon: Icons.feedback_outlined, title: '反馈与举报', action: 'feedback'),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _buildActionTile(icon: Icons.delete_outline, title: '删除', action: 'delete', isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String action,
    bool isDestructive = false,
  }) {
    final Color color = isDestructive ? const Color(0xFFF53F3F) : const Color(0xFF1D1F24);
    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
