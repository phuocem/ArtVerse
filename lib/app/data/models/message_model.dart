class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String type; 

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = 'text',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: _parseDate(json['created_at'] ?? json['timestamp']),
      type: json['type'] as String? ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'content': content,
      'type': type,
    };
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }
}

class ThreadModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastTimestamp;
  final Map<String, int> unreadCount;

  ThreadModel({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastTimestamp,
    this.unreadCount = const {},
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] as String? ?? '',
      participantIds: List<String>.from(json['participant_ids'] as Iterable? ?? []),
      lastMessage: json['last_message'] as String? ?? '',
      lastTimestamp: _parseDate(json['last_timestamp']),
      unreadCount: Map<String, int>.from(json['unread_count'] as Map? ?? {}),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }
}
