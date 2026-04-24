import 'package:artverse/app/data/models/user_model.dart';


class CommentModel {
  final String? id;
  final String data;
  final String userId;
  final DateTime createdAt;
  final String postId;
  UserModel? user;

  CommentModel({
    this.id,
    required this.data,
    required this.userId,
    required this.createdAt,
    required this.postId,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString(),
      data: (json['data'] ?? '').toString(),
      userId: (json['id_user'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      postId: (json['id_post'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'id_user': userId,
      'created_at': createdAt.toIso8601String(),
      'id_post': postId,
    };
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is DateTime) return date;
    return DateTime.now();
  }
}
