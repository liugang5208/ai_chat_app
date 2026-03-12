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
    List<ChatAttachment>? attachments,
    this.knowledgeEntry,
  }) : tags = tags ?? <String>[],
       attachments = attachments ?? <ChatAttachment>[];

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as int,
    fromUser: json['fromUser'] as bool,
    text: json['text'] as String,
    time: DateTime.parse(json['time'] as String),
    tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    attachments:
        (json['attachments'] as List<dynamic>?)
            ?.map(
              (dynamic e) => ChatAttachment.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        <ChatAttachment>[],
    knowledgeEntry: json['knowledgeEntry'] == null
        ? null
        : MessageKnowledgeEntry.fromJson(
            json['knowledgeEntry'] as Map<String, dynamic>,
          ),
  );

  final int id;
  final bool fromUser;
  String text;
  final DateTime time;
  final List<String> tags;
  final List<ChatAttachment> attachments;
  MessageKnowledgeEntry? knowledgeEntry;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'fromUser': fromUser,
    'text': text,
    'time': time.toIso8601String(),
    'tags': tags,
    'attachments': attachments.map((ChatAttachment a) => a.toJson()).toList(),
    'knowledgeEntry': knowledgeEntry?.toJson(),
  };
}

class ChatAttachment {
  ChatAttachment({
    required this.type,
    required this.mimeType,
    required this.fileName,
    required this.base64Data,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) => ChatAttachment(
    type: json['type'] as String,
    mimeType: json['mimeType'] as String,
    fileName: json['fileName'] as String,
    base64Data: json['base64Data'] as String,
  );

  final String type; // image|file
  final String mimeType;
  final String fileName;
  final String base64Data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'mimeType': mimeType,
    'fileName': fileName,
    'base64Data': base64Data,
  };
}

class MessageKnowledgeEntry {
  MessageKnowledgeEntry({
    required this.question,
    required this.answer,
    required this.collectedAt,
    this.tagName,
    this.fromFavorite = false,
  });

  factory MessageKnowledgeEntry.fromJson(Map<String, dynamic> json) =>
      MessageKnowledgeEntry(
        question: json['question'] as String,
        answer: json['answer'] as String,
        collectedAt: DateTime.parse(json['collectedAt'] as String),
        tagName: json['tagName'] as String?,
        fromFavorite: (json['fromFavorite'] as bool?) ?? false,
      );

  final String question;
  final String answer;
  final DateTime collectedAt;
  String? tagName;
  bool fromFavorite;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'question': question,
    'answer': answer,
    'collectedAt': collectedAt.toIso8601String(),
    'tagName': tagName,
    'fromFavorite': fromFavorite,
  };
}
