import 'dart:async';
import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/conversation.dart';
import '../../models/chat_config.dart';
import '../../models/tag_item.dart';
import '../../services/llm_api_service.dart';
import '../../widgets/thinking_dots.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final int conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showInputPanel = false;
  bool _isStreaming = false;
  int? _streamingMsgId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final Conversation conversation = app.getConversationById(
      widget.conversationId,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.remove, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('对话', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            onPressed: () => setState(() => _showInputPanel = !_showInputPanel),
            icon: const Icon(Icons.add_circle, color: Color(0xFF4C84FF)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '17:23',
              style: TextStyle(color: Color(0xFF9FA5B3), fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: conversation.messages.length,
              itemBuilder: (BuildContext context, int index) {
                final ChatMessage message = conversation.messages[index];
                final bool fromUser = message.fromUser;
                final Color bubbleColor = fromUser
                    ? const Color(0xFF4C84FF)
                    : const Color(0xFFF5F6FA);
                final Color textColor = fromUser
                    ? Colors.white
                    : const Color(0xFF1F2633);

                return Align(
                  alignment: fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onLongPress: fromUser
                          ? null
                          : () => _onLongPressAssistantMessage(
                              app,
                              conversation.id,
                              message,
                            ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (!fromUser &&
                                  message.id == _streamingMsgId &&
                                  message.text.isEmpty)
                                const ThinkingDots()
                              else
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    height: 1.55,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (message.tags.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: message.tags
                                      .map(
                                        (String tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9F1FF),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF4C84FF),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputBar(app, conversation),
          if (_isStreaming)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFEEF3FF),
              color: Color(0xFF4C84FF),
              minHeight: 2,
            ),
          if (_showInputPanel) _buildInputPanel(app, conversation),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppState app, Conversation conversation) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDF0F6)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => _showModelSelector(context, app),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF4C84FF)),
                  const SizedBox(width: 4),
                  Text(
                    app.activeVendor != null
                        ? (app.modelConfigs[app.activeVendor]?.model ?? '未配置')
                        : '选择模型',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4C84FF)),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.expand_more, size: 14, color: Color(0xFF4C84FF)),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  app.addUserMessage(conversation.id, '[图片] 拍照上传');
                  app.addAssistantMessage(conversation.id, '已收到图片，你希望我做什么处理？');
                },
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF4A4F5D),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '发消息或者按住说话',
                    hintStyle: TextStyle(color: Color(0xFFB0B5C2), fontSize: 15),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(app, conversation.id),
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(app, conversation.id),
                icon: const Icon(
                  Icons.send,
                  color: Color(0xFF4C84FF),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showInputPanel = !_showInputPanel),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF4A4F5D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(AppState app, Conversation conversation) {
    final List<Map<String, dynamic>> actions = <Map<String, dynamic>>[
      <String, dynamic>{
        'icon': Icons.camera_alt,
        'label': '相机',
        'msg': '[图片] 相机拍摄',
      },
      <String, dynamic>{'icon': Icons.image, 'label': '相册', 'msg': '[图片] 相册选择'},
      <String, dynamic>{
        'icon': Icons.attach_file,
        'label': '文件',
        'msg': '[文件] 文档上传',
      },
      <String, dynamic>{
        'icon': Icons.phone,
        'label': '打电话',
        'msg': '[系统] 发起电话',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFF2F7))),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((Map<String, dynamic> action) {
              return GestureDetector(
                onTap: () {
                  app.addUserMessage(conversation.id, action['msg'] as String);
                  app.addAssistantMessage(
                    conversation.id,
                    '已接收${action['label']}内容。',
                  );
                },
                child: SizedBox(
                  width: 70,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: const Color(0xFF4A4F5D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(action['label'] as String),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, int index) {
                return Container(
                  width: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.lightBlue.shade100,
                        Colors.green.shade100,
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

  Future<void> _sendMessage(AppState app, int conversationId) async {
    final String value = _controller.text.trim();
    if (value.isEmpty || _isStreaming) return;
    _controller.clear();

    app.addUserMessage(conversationId, value);
    _scrollToBottom();

    final ChatConfig? config = app.activeVendor != null
        ? app.modelConfigs[app.activeVendor]
        : null;

    if (config == null) {
      app.addAssistantMessage(conversationId, '请先在"我的"页面配置模型提供方。');
      _scrollToBottom();
      app.saveConversations();
      return;
    }

    final int streamMsgId = app.addStreamingMessage(conversationId);
    setState(() {
      _isStreaming = true;
      _streamingMsgId = streamMsgId;
    });
    _scrollToBottom();

    try {
      final Conversation conv = app.getConversationById(conversationId);
      final List<ChatMessage> history = conv.messages
          .where((ChatMessage m) => m.id != streamMsgId)
          .toList();

      await for (final String chunk in LlmApiService.streamChat(
        config: config,
        history: history,
      )) {
        app.appendToMessage(conversationId, streamMsgId, chunk);
        _scrollToBottom();
      }
    } catch (e) {
      app.updateMessageText(conversationId, streamMsgId, '请求失败：$e');
    } finally {
      setState(() {
        _isStreaming = false;
        _streamingMsgId = null;
      });
      app.saveConversations();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSelector(BuildContext context, AppState app) {
    if (app.modelConfigs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在"我的"页面配置模型提供方')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  '选择模型',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              ...app.modelConfigs.entries.map((MapEntry<String, ChatConfig> e) {
                final bool isActive = app.activeVendor == e.key;
                return ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: Text(e.value.model),
                  subtitle: Text(e.key),
                  trailing: isActive
                      ? const Icon(Icons.check_circle, color: Color(0xFF4C84FF))
                      : null,
                  onTap: () {
                    app.setActiveVendor(e.key);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onLongPressAssistantMessage(
    AppState app,
    int conversationId,
    ChatMessage message,
  ) async {
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.outlined_flag),
                title: const Text('打标签', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('tag'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('收藏', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('favorite'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('导出', style: TextStyle(fontSize: 16)),
                onTap: () => Navigator.of(context).pop('export'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'tag') {
      await _showTagSheet(context, conversationId, message.id);
    } else if (action == 'favorite') {
      app.toggleConversationFavorite(conversationId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已收藏会话')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已导出内容（示例）')));
    }
  }

  Future<void> _showTagSheet(
    BuildContext context,
    int conversationId,
    int messageId,
  ) async {
    String selectedTag = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          '打标签',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '标签类型',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final String? result = await _showTagSelector(context);
                      if (result != null) {
                        setModalState(() => selectedTag = result);
                      }
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedTag.isEmpty ? '请选择' : selectedTag,
                        style: const TextStyle(
                          color: Color(0xFF7E8799),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setModalState(() => selectedTag = ''),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('重置'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final AppState latestApp = AppStateScope.of(
                              context,
                            );
                            final bool exists = latestApp.tags.any(
                              (TagItem t) => t.name == selectedTag,
                            );
                            if (selectedTag.isNotEmpty && exists) {
                              latestApp.assignTagToMessage(
                                conversationId: conversationId,
                                messageId: messageId,
                                tagName: selectedTag,
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C84FF),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('确定'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showTagSelector(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    String current = app.tags.isNotEmpty ? app.tags.first.name : '';

    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final List<TagItem> tags = AppStateScope.of(context).tags;
            if (tags.isEmpty) {
              current = '';
            } else if (!tags.any((TagItem tag) => tag.name == current)) {
              current = tags.first.name;
            }
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        const Expanded(
                          child: Text(
                            '选择标签类型',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(current),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: 220,
                    child: tags.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无可选标签',
                              style: TextStyle(
                                color: Color(0xFF9DA5B5),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView(
                            children: tags.map((TagItem tag) {
                              final bool selected = current == tag.name;
                              return ListTile(
                                title: Text(tag.name),
                                trailing: selected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF4C84FF),
                                      )
                                    : null,
                                onTap: () => setState(() => current = tag.name),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
