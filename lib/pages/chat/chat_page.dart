import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isStreaming = false;
  int? _streamingMsgId;
  bool _isEditingTitle = false;
  bool _isVoicePressing = false;
  DateTime? _voiceStartAt;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();
  bool _speechReady = false;
  String _speechText = '';
  final List<ChatAttachment> _pendingAttachments = <ChatAttachment>[];

  static const int _maxAttachmentBytes = 5 * 1024 * 1024; // 5MB

  @override
  void initState() {
    super.initState();
    unawaited(_initSpeech());
  }

  @override
  void dispose() {
    _speech.cancel();
    _controller.dispose();
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final bool ready = await _speech.initialize();
    if (!mounted) return;
    setState(() {
      _speechReady = ready;
    });
  }

  Future<void> _startVoiceInput() async {
    if (!_speechReady) {
      await _initSpeech();
    }
    if (!_speechReady || !_speech.isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('语音识别不可用，请检查麦克风权限')));
      return;
    }

    await _speech.stop();
    setState(() {
      _isVoicePressing = true;
      _voiceStartAt = DateTime.now();
      _speechText = '';
    });

    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (SpeechRecognitionResult result) {
        if (!mounted) return;
        setState(() {
          _speechText = result.recognizedWords.trim();
        });
      },
    );
  }

  Future<void> _finishVoiceInput(AppState app, int conversationId) async {
    if (!_isVoicePressing) return;
    await _speech.stop();
    final DateTime startedAt = _voiceStartAt ?? DateTime.now();
    final int seconds = DateTime.now()
        .difference(startedAt)
        .inSeconds
        .clamp(1, 60);
    final String recognized = _speechText.trim();

    if (mounted) {
      setState(() {
        _isVoicePressing = false;
        _voiceStartAt = null;
      });
    }

    if (recognized.isEmpty) {
      app.addAssistantMessage(
        conversationId,
        '未识别到语音内容，请重试（录音时长 ${seconds}s）。',
      );
      _scrollToBottom();
      return;
    }

    _controller.text = recognized;
    await _sendMessage(app, conversationId);
  }

  String _guessMimeType(String fileName, {bool image = false}) {
    final String lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.json')) return 'application/json';
    if (lower.endsWith('.md')) return 'text/markdown';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (image) return 'image/jpeg';
    return 'application/octet-stream';
  }

  Future<void> _addAttachmentFromXFile(
    XFile file, {
    required String type,
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.length > _maxAttachmentBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('附件过大，单个文件请控制在 5MB 以内')));
      return;
    }
    final ChatAttachment attachment = ChatAttachment(
      type: type,
      mimeType: _guessMimeType(file.name, image: type == 'image'),
      fileName: file.name,
      base64Data: base64Encode(bytes),
    );
    if (!mounted) return;
    setState(() => _pendingAttachments.add(attachment));
  }

  Future<void> _pickFromCamera() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (file == null) return;
    await _addAttachmentFromXFile(file, type: 'image');
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return;
    await _addAttachmentFromXFile(file, type: 'image');
  }

  Future<void> _pickFromFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final PlatformFile file = result.files.single;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('读取文件失败，请重试')));
      return;
    }
    if (bytes.length > _maxAttachmentBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('附件过大，单个文件请控制在 5MB 以内')));
      return;
    }
    final String fileName = file.name;
    final ChatAttachment attachment = ChatAttachment(
      type: 'file',
      mimeType: _guessMimeType(fileName),
      fileName: fileName,
      base64Data: base64Encode(bytes),
    );
    if (!mounted) return;
    setState(() => _pendingAttachments.add(attachment));
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final Conversation conversation = app.getConversationById(
      widget.conversationId,
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 240,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.menu,
                        size: 20,
                        color: Color(0xFF3A3F4B),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showModelSelector(context, app),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            app.activeVendor ?? '未选择厂商',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1F24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            app.activeVendor != null
                                ? (app
                                          .modelConfigs[app.activeVendor]
                                          ?.effectiveModel ??
                                      '未选择模型')
                                : '未选择模型',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9197A5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: Color(0xFF9197A5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        title: _isEditingTitle
            ? TextField(
                controller: _titleController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (String value) {
                  final String normalized = value.trim();
                  if (normalized.isNotEmpty) {
                    AppStateScope.of(
                      context,
                    ).renameConversation(widget.conversationId, normalized);
                  }
                  setState(() => _isEditingTitle = false);
                },
                onTapOutside: (_) {
                  final String normalized = _titleController.text.trim();
                  if (normalized.isNotEmpty) {
                    AppStateScope.of(
                      context,
                    ).renameConversation(widget.conversationId, normalized);
                  }
                  setState(() => _isEditingTitle = false);
                },
              )
            : GestureDetector(
                onTap: () {
                  _titleController.text = conversation.title;
                  setState(() => _isEditingTitle = true);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        conversation.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: Color(0xFF9FA5B3),
                    ),
                  ],
                ),
              ),
        actions: const <Widget>[],
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

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: fromUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!fromUser) ...<Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFEEF3FF),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Color(0xFF4C84FF),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      GestureDetector(
                        onLongPress: fromUser
                            ? null
                            : () => _onLongPressAssistantMessage(
                                app,
                                conversation.id,
                                message,
                              ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.68,
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                      if (fromUser) ...<Widget>[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF4C84FF),
                          child: const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
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
          Row(
            children: <Widget>[
              IconButton(
                onPressed: _pickFromCamera,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF4A4F5D),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    unawaited(_startVoiceInput());
                  },
                  onLongPressEnd: (_) {
                    unawaited(_finishVoiceInput(app, conversation.id));
                  },
                  onLongPressCancel: () {
                    unawaited(_finishVoiceInput(app, conversation.id));
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isVoicePressing
                        ? Center(
                            child: Text(
                              _speechText.isNotEmpty
                                  ? _speechText
                                  : '正在识别，松开发送',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4C84FF),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: '发消息或长按语音输入',
                              hintStyle: TextStyle(
                                color: Color(0xFFB0B5C2),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) =>
                                _sendMessage(app, conversation.id),
                          ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(app, conversation.id),
                icon: const Icon(Icons.send, color: Color(0xFF4C84FF)),
              ),
              IconButton(
                onPressed: _showAttachmentSheet,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF4A4F5D),
                ),
              ),
            ],
          ),
          if (_pendingAttachments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _pendingAttachments.asMap().entries.map((
                  MapEntry<int, ChatAttachment> entry,
                ) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          entry.value.fileName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A4F5D),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _pendingAttachments.removeAt(entry.key);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF8A90A0),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAttachmentSheet() async {
    final List<Map<String, dynamic>> actions = <Map<String, dynamic>>[
      <String, dynamic>{
        'asset': 'assets/input_camera.png',
        'label': '相机',
        'action': _pickFromCamera,
      },
      <String, dynamic>{
        'asset': 'assets/input_photos.png',
        'label': '相册',
        'action': _pickFromGallery,
      },
      <String, dynamic>{
        'asset': 'assets/input_file.png',
        'label': '文件',
        'action': _pickFromFile,
      },
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions.map((Map<String, dynamic> action) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    final Future<void> Function() fn =
                        action['action'] as Future<void> Function();
                    unawaited(fn());
                  },
                  child: SizedBox(
                    width: 86,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            action['asset'] as String,
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A4F5D),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage(AppState app, int conversationId) async {
    final String value = _controller.text.trim();
    final List<ChatAttachment> attachments = List<ChatAttachment>.from(
      _pendingAttachments,
    );
    if ((value.isEmpty && attachments.isEmpty) || _isStreaming) return;
    _controller.clear();
    if (mounted && attachments.isNotEmpty) {
      setState(() {
        _pendingAttachments.clear();
      });
    }

    final String displayText = value.isNotEmpty
        ? value
        : '[附件] ${attachments.map((ChatAttachment a) => a.fileName).join(', ')}';
    app.addUserMessage(conversationId, displayText, attachments: attachments);
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
        if (!mounted) break;
        app.appendToMessage(conversationId, streamMsgId, chunk);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        app.updateMessageText(conversationId, streamMsgId, '请求失败：$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _streamingMsgId = null;
        });
      }
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
    String? hoveredVendor;

    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final List<String> vendors = app.modelConfigs.keys.toList();
            return Stack(
              children: <Widget>[
                Positioned(
                  top: 60,
                  left: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // First level: Vendors
                        Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: vendors.map((String vendor) {
                              final bool isSelected =
                                  app.activeVendor == vendor;
                              final bool isHovered = hoveredVendor == vendor;
                              return InkWell(
                                onHover: (bool value) {
                                  if (value) {
                                    setState(() => hoveredVendor = vendor);
                                  }
                                },
                                onTap: () {
                                  setState(() => hoveredVendor = vendor);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  color: isHovered
                                      ? const Color(0xFFF5F7FA)
                                      : Colors.transparent,
                                  child: Row(
                                    children: <Widget>[
                                      if (isSelected)
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Color(0xFF1D1F24),
                                        )
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          vendor,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1D1F24),
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Color(0xFF9197A5),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (hoveredVendor != null &&
                            app.modelConfigs.containsKey(
                              hoveredVendor!,
                            )) ...<Widget>[
                          const SizedBox(width: 8),
                          // Second level: Models for the selected vendor
                          Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: (() {
                                final String hv = hoveredVendor!;
                                final ChatConfig config = app.modelConfigs[hv]!;
                                final List<String> models =
                                    config.models
                                        .where(
                                          (String m) => m.trim().isNotEmpty,
                                        )
                                        .toList()
                                        .isNotEmpty
                                    ? config.models
                                          .where(
                                            (String m) => m.trim().isNotEmpty,
                                          )
                                          .toList()
                                    : <String>[config.effectiveModel];

                                return models.map((String modelName) {
                                  final bool isActive =
                                      app.activeVendor == hv &&
                                      config.effectiveModel == modelName;
                                  return InkWell(
                                    onTap: () {
                                      app.setActiveModelForVendor(
                                        vendor: hv,
                                        modelName: modelName,
                                      );
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              modelName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1D1F24),
                                              ),
                                            ),
                                          ),
                                          if (isActive)
                                            const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Color(0xFF1D1F24),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList();
                              })(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
      app.saveAssistantMessageToKnowledge(
        conversationId: conversationId,
        messageId: message.id,
        fromFavorite: true,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已收藏并加入文件夹')));
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
                              latestApp.saveAssistantMessageToKnowledge(
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
