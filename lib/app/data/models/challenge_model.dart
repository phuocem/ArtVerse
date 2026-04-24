

class ChallengeModel {
  final String id;
  final String title;
  final String prompt;
  final int rewardXp;
  final String? badgeId;
  final DateTime startAt;
  final DateTime endAt;
  final String? imageUrl;
  final int participantsCount;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.prompt,
    this.rewardXp = 500,
    this.badgeId,
    required this.startAt,
    required this.endAt,
    this.imageUrl,
    this.participantsCount = 0,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final idValue = docId ?? json['id'] as String? ?? '';
    return ChallengeModel(
      id: idValue,
      title: json['title'] as String? ?? 'Untitled Challenge',
      prompt: json['prompt'] as String? ?? '',
      rewardXp: json['reward_xp'] as int? ?? 500,
      badgeId: json['badge_id'] as String?,
      startAt: _parseDate(json['start_at'] ?? json['createdAt']),
      endAt: _parseDate(json['end_at']),
      imageUrl: json['image_url'] as String?,
      participantsCount: json['participants_count'] as int? ?? 0,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now().add(const Duration(days: 1));
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is DateTime) return date;
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'reward_xp': rewardXp,
      'badge_id': badgeId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'image_url': imageUrl,
      'participants_count': participantsCount,
    };
  }
}
