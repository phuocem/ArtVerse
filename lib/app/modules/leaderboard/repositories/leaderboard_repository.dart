import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardRepository {
  final LeaderboardProvider provider;

  LeaderboardRepository({required this.provider});

  Future<List<UserModel>> fetchTopArtists({
    required String field,
    int limit = 20,
    String? timeframe,
  }) async {
    try {
      final snapshot = await provider.getTopArtists(
        field: field, 
        limit: limit,
        timeframe: timeframe,
      );

      return snapshot.map((data) {
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> fetchUserGlobalRank(String userId, String field) async {
    try {
      final snapshot = await provider.getTopArtists(field: field, limit: 1000);
      final index = snapshot.indexWhere((doc) => doc['id'] == userId);
      return index != -1 ? index + 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<UserModel>> fetchRegionalRankings(String region) async {
    try {
      final snapshot = await provider.getRegionalLeaderboard(region);
      return snapshot.map((data) {
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateSeasonalProgress(String seasonId, String userId, int points) async {
    try {
      if (points == 0) return;
      await provider.updateSeasonalScore(seasonId, userId, points);
    } catch (e) {
      rethrow;
    }
  }

  String calculateArtistTier(int exp) {
    if (exp >= 100000) return '🌸 Master 💗';
    if (exp >= 50000) return '🌸 Diamond 💗';
    if (exp >= 25000) return '🌸 Platinum 💗';
    if (exp >= 10000) return '🌸 Gold 💗';
    if (exp >= 5000) return '🌸 Silver 💗';
    return '🌸 Bronze 💗';
  }

  Future<void> nominateOutstandingArtist(String userId, String reason) async {
    try {
      if (reason.trim().isEmpty) throw Exception('Nomination reason is required');
      await provider.nominateToHallOfFame(userId, reason);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHallOfFameEntries() async {
    try {
      final snapshot = await provider.getHallOfFame();
      return snapshot;
    } catch (e) {
      return [];
    }
  }

  Future<void> logRankChange(String userId, int oldRank, int newRank, String field) async {
    try {
      if (oldRank == newRank) return;
      await provider.recordUserRankHistory(userId, {
        'metric': field,
        'previous_rank': oldRank,
        'current_rank': newRank,
        'change': oldRank - newRank,
      });
    } catch (e) {
    }
  }

  Color getTierColor(String tier) {
    if (tier.contains('Master')) return const Color(0xFFFF1493);
    if (tier.contains('Diamond')) return const Color(0xFFC0C0C0);
    if (tier.contains('Gold')) return const Color(0xFFFFD700);
    return const Color(0xFFFF69B4);
  }
}
