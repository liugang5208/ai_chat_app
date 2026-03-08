class Conversation {
  Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.messages,
    this.favorite = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as int,
        title: json['title'] as String,
        preview: json['preview'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        favorite: (json['favorite'] as bool?) ?? false,
        messages: (json['messages'] as List<dynamic>)
            .map((dynamic e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  String title;
  String preview;
  DateTime updatedAt;
  bool favorite;
  final List<ChatMessage> messages;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'preview': preview,
        'updatedAt': updatedAt.toIso8601String(),
        'favorite': favorite,
        'messages': messages.map((ChatMessage m) => m.toJson()).toList(),
      };
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fromUser,
    required this.text,
    required this.time,
    List<String>? tags,
  }) : tags = tags ?? <String>[];

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        fromUser: json['fromUser'] as bool,
        text: json['text'] as String,
        time: DateTime.parse(json['time'] as String),
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      );

  final int id;
  final bool fromUser;
  String text;
  final DateTime time;
  final List<String> tags;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fromUser': fromUser,
        'text': text,
        'time': time.toIso8601String(),
        'tags': tags,
      };
}
