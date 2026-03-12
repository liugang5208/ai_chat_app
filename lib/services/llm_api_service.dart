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
        'messages': history
            .map(
              (ChatMessage m) => <String, String>{
                'role': m.fromUser ? 'user' : 'assistant',
                'content': m.text,
              },
            )
            .toList(),
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
      await for (final String chunk in response.stream.transform(
        utf8.decoder,
      )) {
        buffer += chunk;
        final List<String> lines = buffer.split('\n');
        buffer = lines.removeLast();
        for (final String line in lines) {
          if (line.startsWith('data: ')) {
            final String data = line.substring(6).trim();
            if (data == '[DONE]') return;
            try {
              final Map<String, dynamic> json =
                  jsonDecode(data) as Map<String, dynamic>;
              final String? delta =
                  ((json['choices'] as List<dynamic>?)?.first
                          as Map<String, dynamic>?)?['delta']?['content']
                      as String?;
              if (delta != null && delta.isNotEmpty) yield delta;
            } catch (_) {}
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
