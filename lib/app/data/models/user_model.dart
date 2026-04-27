import 'package:hive/hive.dart';
part 'user_model.g.dart';
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0) String? id;
  @HiveField(1) DateTime createdAt;
  @HiveField(2) DateTime editedAt;
  @HiveField(3) String name;
  @HiveField(4) String bio;
  @HiveField(5) String email;
  @HiveField(6) String? avatarUrl;
  @HiveField(7) int followersCount;
  @HiveField(8) int followingCount;
  @HiveField(9) String? location;
  @HiveField(10) String? website;
  @HiveField(11) String? instagramUrl;
  @HiveField(12) String? twitterUrl;
  @HiveField(13) bool isStudio;
  @HiveField(14) double balance;
  @HiveField(15) int likesCount;
  @HiveField(16) int viewsCount;
  @HiveField(17, defaultValue: false) bool isVerified;
  @HiveField(18) List<String>? specialties;
  @HiveField(19) List<Map<String, dynamic>>? tools;
  @HiveField(20) String? handle;
  @HiveField(21) String? selectedFrame;
  @HiveField(22) String? gender;
  @HiveField(23) int xp;
  @HiveField(24) int level;
  @HiveField(25) List<String>? badges;
  @HiveField(26) String? coverUrl;
  UserModel({this.id, required this.createdAt, required this.editedAt, required this.name, required this.bio, required this.email, this.avatarUrl, this.followersCount = 0, this.followingCount = 0, this.location, this.website, this.instagramUrl, this.twitterUrl, this.isStudio = false, this.balance = 0.0, this.likesCount = 0, this.viewsCount = 0, this.isVerified = false, this.specialties, this.tools, this.handle, this.selectedFrame, this.gender, this.xp = 0, this.level = 1, this.badges, this.coverUrl});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      editedAt: _parseDate(json['edited_at']),
      name: (json['name'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      followersCount: _parseInt(json['followers_count']),
      followingCount: _parseInt(json['following_count']),
      location: json['location']?.toString(),
      website: json['website']?.toString(),
      instagramUrl: json['instagram_url']?.toString(),
      twitterUrl: json['twitter_url']?.toString(),
      isStudio: (json['is_studio']) as bool? ?? false,
      balance: _parseDouble(json['balance']),
      likesCount: _parseInt(json['likes_count']),
      viewsCount: _parseInt(json['views_count']),
      isVerified: json['is_verified'] as bool? ?? false,
      specialties: _parseStringList(json['specialties']),
      tools: _parseMapList(json['tools']),
      handle: json['handle']?.toString(),
      selectedFrame: json['selected_frame']?.toString(),
      gender: json['gender']?.toString(),
      xp: _parseInt(json['xp']),
      level: _parseInt(json['level']) == 0 ? 1 : _parseInt(json['level']),
      badges: _parseStringList(json['badges']),
      coverUrl: json['cover_url']?.toString(),
    );
  }
  static List<String> _parseStringList(dynamic value) => value is List ? value.map((e) => e.toString()).toList() : [];
  static List<Map<String, dynamic>> _parseMapList(dynamic value) => value is List ? value.map((e) => Map<String, dynamic>.from(e as Map)).toList() : [];
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  Map<String, dynamic> toJson() {
    return {'created_at': createdAt.toIso8601String(), 'edited_at': editedAt.toIso8601String(), 'name': name, 'bio': bio, 'email': email, 'avatar_url': avatarUrl, 'followers_count': followersCount, 'following_count': followingCount, 'location': location, 'website': website, 'instagram_url': instagramUrl, 'twitter_url': twitterUrl, 'is_studio': isStudio, 'balance': balance, 'likes_count': likesCount, 'views_count': viewsCount, 'is_verified': isVerified, 'specialties': specialties, 'tools': tools, 'handle': handle, 'selected_frame': selectedFrame, 'gender': gender, 'xp': xp, 'level': level, 'badges': badges, 'cover_url': coverUrl};
  }
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }
}
