class ResourceModel {
  final String? id;
  final String name;
  final String type; 
  final String? description;
  final String authorId;
  final String authorName;
  final String thumbnailUrl;
  final String? lottieUrl;
  final bool isLottie;
  final String? fileUrl; 
  final List<String>? colors; 
  final int downloadsCount;
  final DateTime createdAt;

  ResourceModel({
    this.id,
    required this.name,
    required this.type,
    this.description,
    required this.authorId,
    required this.authorName,
    required this.thumbnailUrl,
    this.lottieUrl,
    this.isLottie = false,
    this.fileUrl,
    this.colors,
    this.downloadsCount = 0,
    required this.createdAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id']?.toString(),
      name: (json['name'] ?? 'Unknown Resource').toString(),
      type: (json['type'] ?? 'unknown').toString(),
      description: json['description']?.toString(),
      authorId: (json['author_id'] ?? '').toString(),
      authorName: (json['author_name'] ?? 'System').toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? '').toString(),
      lottieUrl: json['lottie_url']?.toString(),
      isLottie: json['is_lottie'] ?? false,
      fileUrl: json['file_url']?.toString(),
      colors: _parseColors(json['colors']),
      downloadsCount: _parseInt(json['downloads_count']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static List<String>? _parseColors(dynamic colors) {
    if (colors == null) return null;
    if (colors is List) {
      return colors.map((e) => e.toString()).toList();
    }
    return null;
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
      'name': name,
      'type': type,
      'description': description,
      'author_id': authorId,
      'author_name': authorName,
      'thumbnail_url': thumbnailUrl,
      'lottie_url': lottieUrl,
      'is_lottie': isLottie,
      if (fileUrl != null) 'file_url': fileUrl,
      if (colors != null) 'colors': colors,
      'downloads_count': downloadsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
