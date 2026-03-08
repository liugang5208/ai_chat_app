import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/conversation.dart';

class ConversationStorage {
  static Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/conversations.json');
  }

  static Future<
      ({
        List<Conversation> conversations,
        int nextConvId,
        int nextMsgId,
      })> load() async {
    try {
      final File file = await _file();
      if (!file.existsSync()) {
        return (conversations: <Conversation>[], nextConvId: 1, nextMsgId: 1);
      }
      final Map<String, dynamic> data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final List<Conversation> convs = (data['conversations'] as List<dynamic>)
          .map((dynamic e) =>
              Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
      return (
        conversations: convs,
        nextConvId: (data['nextConvId'] as int?) ?? convs.length + 1,
        nextMsgId: (data['nextMsgId'] as int?) ?? 1,
      );
    } catch (_) {
      return (conversations: <Conversation>[], nextConvId: 1, nextMsgId: 1);
    }
  }

  static Future<void> save(
    List<Conversation> conversations,
    int nextConvId,
    int nextMsgId,
  ) async {
    final File file = await _file();
    await file.writeAsString(jsonEncode(<String, dynamic>{
      'nextConvId': nextConvId,
      'nextMsgId': nextMsgId,
      'conversations':
          conversations.map((Conversation c) => c.toJson()).toList(),
    }));
  }
}
