import 'package:artverse/app/data/models/user_model.dart';

class PostModel {
  final String? id;
  final DateTime createdAt;
  final DateTime editedAt;
  final String name;
  final String? description;
  final String url;
  final int status;
  final String userId;
  final int views;
  final int likesCount;
  final String thumbnail;
  final String? projectFileUrl;
  final String? category;
  final String? fileType;
  final String? parentId; 
  final List<String>? coAuthorIds; 
  UserModel? user;
  
  bool get isVideo {
    final lowUrl = url.toLowerCase();
    return lowUrl.contains('.mp4') || 
           lowUrl.contains('.m3u8') || 
           lowUrl.contains('.mov') || 
           lowUrl.contains('.avi') || 
           lowUrl.contains('.flv') || 
           lowUrl.contains('.wmv') || 
           lowUrl.contains('/videos/');
  }


  PostModel({
    this.id,
    required this.createdAt,
    required this.editedAt,
    required this.name,
    this.description,
    required this.url,
    required this.status,
    required this.userId,
    required this.views,
    this.likesCount = 0,
    required this.thumbnail,
    this.projectFileUrl,
    this.category,
    this.fileType,
    this.parentId,
    this.coAuthorIds,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString(),
      createdAt: _parseDate(json['created_at']),
      editedAt: _parseDate(json['edited_at']),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      url: (json['url'] ?? '').toString(),
      status: _parseInt(json['status']),
      userId: (json['user_id'] ?? '').toString(),
      views: _parseInt(json['views']),
      likesCount: _parseInt(json['likes_count']),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      projectFileUrl: json['project_file_url']?.toString(),
      category: json['category']?.toString(),
      fileType: json['file_type']?.toString() ?? _inferFileType((json['url'] ?? '').toString()),
      parentId: json['parent_id']?.toString(),
      coAuthorIds: json['co_author_ids'] != null ? List<String>.from(json['co_author_ids'] as Iterable) : null,
    );
  }

  static String _inferFileType(String url) {
    if (url.isEmpty) return 'PNG';
    final parts = url.split('.');
    if (parts.length > 1) {
      final ext = parts.last.toUpperCase();
      if (['PNG', 'JPG', 'JPEG', 'PSD', 'MP4', 'MOV'].contains(ext)) return ext;
    }
    return 'PNG';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt.toIso8601String(),
      'name': name,
      'description': description,
      'url': url,
      'status': status,
      'user_id': userId,
      'views': views,
      'likes_count': likesCount,
      'thumbnail': thumbnail,
      if (projectFileUrl != null) 'project_file_url': projectFileUrl,
      if (category != null) 'category': category,
      if (fileType != null) 'file_type': fileType,
      if (parentId != null) 'parent_id': parentId,
      if (coAuthorIds != null) 'co_author_ids': coAuthorIds,
    };
  }

  PostModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? editedAt,
    String? name,
    String? description,
    String? url,
    int? status,
    String? userId,
    int? views,
    int? likesCount,
    String? thumbnail,
    String? projectFileUrl,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      views: views ?? this.views,
      likesCount: likesCount ?? this.likesCount,
      thumbnail: thumbnail ?? this.thumbnail,
      projectFileUrl: projectFileUrl ?? this.projectFileUrl,
      category: category ?? category,
    );
  }
}
