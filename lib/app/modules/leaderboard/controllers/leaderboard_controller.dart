import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/app_globals.dart';
import '../repositories/leaderboard_repository.dart';

class LeaderboardController extends GetxController {
  final LeaderboardRepository repository;

  LeaderboardController({required this.repository});

  final isLoading = true.obs;
  final selectedCategory = 'likes'.obs;
  final selectedTimeframe = 'all_time'.obs;

  final Map<String, DateTime> _lastFetchTimes = {};
  final Map<String, List<UserModel>> _dataCache = {};

  final activeList = <UserModel>[].obs;
  final regionalRankings = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboards();
  }

  Future<void> fetchLeaderboards({bool force = false}) async {
    final cat = selectedCategory.value;
    final timeframe = selectedTimeframe.value;
    final cacheKey = '${cat}_$timeframe';

    if (!force && _lastFetchTimes.containsKey(cacheKey) && _dataCache.containsKey(cacheKey)) {
      final diff = DateTime.now().difference(_lastFetchTimes[cacheKey]!);
      if (diff.inSeconds < 60) {
        activeList.assignAll(_dataCache[cacheKey]!);
        isLoading.value = false;
        return;
      }
    }

    isLoading.value = true;
    try {
      final fieldMap = {
        'likes': 'likes_count',
        'followers': 'followers_count',
        'wealth': 'balance',
        'views': 'views_count',
      };

      final String field = fieldMap[cat] ?? 'likes_count';

      final users = await repository.fetchTopArtists(
        field: field,
        timeframe: timeframe,
      );

      _dataCache[cacheKey] = users;
      _lastFetchTimes[cacheKey] = DateTime.now();
      activeList.assignAll(users);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;

    final cacheKey = '${category}_${selectedTimeframe.value}';
    if (_dataCache.containsKey(cacheKey)) {
      activeList.assignAll(_dataCache[cacheKey]!);
    }
    fetchLeaderboards();
  }

  void changeTimeframe(String timeframe) {
    if (selectedTimeframe.value == timeframe) return;
    selectedTimeframe.value = timeframe;
    fetchLeaderboards(force: true);
  }

  Future<void> fetchRegional(String region) async {
    isLoading.value = true;
    try {
      final users = await repository.fetchRegionalRankings(region);
      regionalRankings.assignAll(users);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  String get categoryLabel {
    switch (selectedCategory.value) {
      case 'likes': return '🌸 Most Liked Artists 💗';
      case 'followers': return '🌸 Top Followed 💗';
      case 'wealth': return '🌸 Wealthiest Creators 💗';
      case 'views': return '🌸 Most Viewed Studio 💗';
      default: return '🌸 Visionary Rankings 💗';
    }
  }

  String getArtistTier(int exp) {
    return repository.calculateArtistTier(exp);
  }

  Color getTierColor(String tier) {
    return repository.getTierColor(tier);
  }

  Future<void> nominateArtist(String userId, String reason) async {
    try {
      await repository.nominateOutstandingArtist(userId, reason);
      _showSuccessSnackbar('Nominated 🌸', 'Artist nominated for Hall of Fame 💗');
    } catch (e) {
      _showErrorSnackbar('Error', 'Could not nominate artist');
    }
  }

  void _showSuccessSnackbar(String title, String message) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🌸 $title 💗", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
      backgroundColor: const Color(0xFFFF69B4).withValues(alpha: 0.9),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  void _showErrorSnackbar(String title, String message) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🌸 $title 💗", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }
}
