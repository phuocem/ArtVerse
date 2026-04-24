
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/achievement_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/database_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../providers/dashboard_provider.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final _repository = DashboardRepository(DashboardProvider());
  final profileController = Get.find<ProfileController>();
  final databaseService = Get.find<DatabaseService>();

  final totalViews = 0.obs;
  final totalLikes = 0.obs;
  final totalArtworks = 0.obs;
  final followerCount = 0.obs;

  final recentProjects = <PostModel>[].obs;
  final trendingProjects = <PostModel>[].obs;
  final isLoading = true.obs;
  final achievements = <AchievementModel>[].obs;

  final selectedPeriod = 'Month'.obs;
  final chartValues = <double>[].obs;
  final recentActivities = <Map<String, String>>[].obs;

  final styleDNA = <String, double>{
    'Contrast': 0.7,
    'Complexity': 0.5,
    'Continuity': 0.8,
    'Vibrancy': 0.6,
    'Impact': 0.4,
  }.obs;

  String get styleTag {
    if (styleDNA['Impact']! > 0.8) return 'Elite Visionary';
    if (styleDNA['Continuity']! > 0.8) return 'Dedicated Creator';
    if (styleDNA['Complexity']! > 0.8) return 'Master of Detail';
    if (styleDNA['Vibrancy']! > 0.8) return 'Color Alchemist';
    if (styleDNA['Contrast']! > 0.8) return 'Shadow Architect';
    return 'Rising Artist';
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void selectPeriod(String period) {
    selectedPeriod.value = period;
    _updateChartForPeriod(period);
  }

  void _updateChartForPeriod(String period) {
    final int totalV = totalViews.value.clamp(1, 999999);
    switch (period) {
      case 'Week':
        chartValues.assignAll([0.2, 0.35, 0.3, 0.5, 0.4, 0.6, (totalV / 1000).clamp(0.1, 1.0)]);
        break;
      case 'Year':
        chartValues.assignAll([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.65, 0.75, 0.8, 0.85, (totalV / 1000).clamp(0.1, 1.0)]);
        break;
      default:
        chartValues.assignAll([0.3, 0.4, 0.35, 0.55, 0.5, 0.7, (totalV / 1000).clamp(0.1, 1.0)]);
    }
  }

  Future<void> fetchDashboardData() async {
    final user = profileController.currentUser.value;
    if (user == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final userPosts = await _repository.getUserPosts(user.id ?? '')
          .timeout(const Duration(seconds: 10), onTimeout: () => <PostModel>[]);

      totalArtworks.value = userPosts.length;
      int views = 0;
      int likes = 0;
      for (final post in userPosts) {
        views += (post.views as num).toInt();
        likes += (post.likesCount as num).toInt();
      }
      totalViews.value = views;
      totalLikes.value = likes;
      followerCount.value = user.followersCount;

      final List<PostModel> sortedPosts = List.from(userPosts)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentProjects.assignAll(sortedPosts.take(5).toList());

      recentActivities.assignAll(
        sortedPosts.take(6).map((p) => {
          'title': p.name.isNotEmpty ? p.name : 'Tác phẩm mới',
          'subtitle': 'Đã đăng lên cộng đồng',
          'time': _timeAgo(p.createdAt),
        }).toList(),
      );

      final trending = await _repository.getTrendingPosts()
          .timeout(const Duration(seconds: 10), onTimeout: () => <PostModel>[]);
      trendingProjects.assignAll(trending);

      _updateChartForPeriod(selectedPeriod.value);
      _calculateStyleDNA();
      _evaluateAchievements();
    } catch (_) {
      _calculateStyleDNA();
      _evaluateAchievements();
    } finally {
      isLoading.value = false;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }

  void _calculateStyleDNA() {
    final double continuity = (totalArtworks.value / 15).clamp(0.0, 1.0);
    final double impact = (totalViews.value / 1000).clamp(0.0, 1.0);
    final double contrast = (followerCount.value / 50).clamp(0.0, 1.0);
    final double vibrancy = (totalLikes.value / 500).clamp(0.0, 1.0);
    final double complexity = (totalArtworks.value > 0
            ? totalLikes.value / totalArtworks.value / 20
            : 0.0)
        .clamp(0.0, 1.0);

    styleDNA.value = {
      'Contrast': contrast,
      'Complexity': complexity,
      'Continuity': continuity,
      'Vibrancy': vibrancy,
      'Impact': impact,
    };
  }

  void _evaluateAchievements() {
    final List<AchievementModel> earned = [];

    
    final now = DateTime.now();
    final isNight = now.hour >= 22 || now.hour <= 4;
    earned.add(
      AchievementModel(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Creating masterpieces past midnight.',
        icon: Icons.nights_stay_rounded,
        gradientColors: [const Color(0xFF6B21A8), const Color(0xFF312E81)],
        isUnlocked: isNight,
      ),
    );

    
    earned.add(
      AchievementModel(
        id: 'dedicated',
        title: 'Dedicated',
        description: 'Created over 5 artworks.',
        icon: Icons.local_fire_department_rounded,
        gradientColors: [const Color(0xFFF97316), const Color(0xFFDC2626)],
        isUnlocked: totalArtworks.value >= 5,
      ),
    );

    
    earned.add(
      AchievementModel(
        id: 'alchemist',
        title: 'Alchemist',
        description: 'Saved custom palettes from Marketplace.',
        icon: Icons.palette_rounded,
        gradientColors: [const Color(0xFF10B981), const Color(0xFF3B82F6)],
        isUnlocked: databaseService.settingsBox.get('custom_palettes') != null,
      ),
    );

    
    earned.add(
      AchievementModel(
        id: 'popular',
        title: 'Star',
        description: 'Reached 100 followers.',
        icon: Icons.star_rounded,
        gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        isUnlocked: followerCount.value >= 100,
      ),
    );

    achievements.assignAll(earned);
  }
}
