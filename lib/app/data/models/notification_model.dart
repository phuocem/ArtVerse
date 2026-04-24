class NotificationModel {
  final String id;
  final String type; 
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String targetId;
  final String? linkId; 
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.targetId,
    this.linkId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'ArtVerse',
      senderAvatar: json['sender_avatar'] as String?,
      targetId: json['target_id'] as String? ?? '',
      linkId: json['link_id'] as String?,
      message: json['message'] as String? ?? '',
      timestamp: _parseDate(json['created_at'] ?? json['timestamp']),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'target_id': targetId,
      'link_id': linkId,
      'message': message,
      'is_read': isRead,
    };
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }
}
