import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/chat_config.dart';

class LlmApiService {
  static const int _maxCompletionTokens = 4096;
  static const double _temperature = 0.7;

  static Stream<String> streamChat({
    required ChatConfig config,
    required List<ChatMessage> history,
  }) async* {
    final http.Client client = http.Client();
    try {
      final http.Request request = http.Request(
        'POST',
        Uri.parse('${config.baseUrl}/chat/completions'),
      );
      request.headers['Authorization'] = 'Bearer ${config.apiKey}';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(<String, dynamic>{
        'model': config.effectiveModel,
        'messages': history.map(_mapMessage).toList(),
        'temperature': _temperature,
        'max_tokens': _maxCompletionTokens,
        'stream': true,
      });

      final http.StreamedResponse response = await client.send(request);
      if (response.statusCode != 200) {
        final String body = await response.stream.bytesToString();
        throw Exception('HTTP ${response.statusCode}: $body');
      }

      String buffer = '';
      bool streamFinished = false;
      await for (final String chunk in response.stream.transform(
        utf8.decoder,
      )) {
        buffer += chunk;
        final List<String> lines = buffer.split('\n');
        buffer = lines.removeLast();
        for (final String line in lines) {
          if (line.startsWith('data: ')) {
            final String data = line.substring(6).trim();
            if (data == '[DONE]') {
              streamFinished = true;
              return;
            }
            try {
              final Map<String, dynamic> json =
                  jsonDecode(data) as Map<String, dynamic>;
              final Map<String, dynamic>? choice =
                  ((json['choices'] as List<dynamic>?)?.first
                      as Map<String, dynamic>?);
              final String? delta =
                  (choice?['delta'] as Map<String, dynamic>?)?['content']
                      as String?;
              if (delta != null && delta.isNotEmpty) yield delta;
              if (choice?['finish_reason'] != null) {
                streamFinished = true;
              }
            } catch (_) {}
          }
        }
      }
      if (!streamFinished) {
        throw Exception('Stream ended unexpectedly');
      }
    } finally {
      client.close();
    }
  }

  static Map<String, dynamic> _mapMessage(ChatMessage m) {
    if (!m.fromUser || m.attachments.isEmpty) {
      return <String, dynamic>{
        'role': m.fromUser ? 'user' : 'assistant',
        'content': m.text,
      };
    }

    final List<Map<String, dynamic>> content = <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'text',
        'text': m.text.isEmpty ? '请分析附件内容。' : m.text,
      },
    ];

    for (final ChatAttachment a in m.attachments) {
      if (a.mimeType.startsWith('image/')) {
        content.add(<String, dynamic>{
          'type': 'image_url',
          'image_url': <String, dynamic>{
            'url': 'data:${a.mimeType};base64,${a.base64Data}',
          },
        });
      } else {
        content.add(<String, dynamic>{
          'type': 'text',
          'text': '文件(${a.fileName}, ${a.mimeType}) base64:\n${a.base64Data}',
        });
      }
    }

    return <String, dynamic>{'role': 'user', 'content': content};
  }
}
