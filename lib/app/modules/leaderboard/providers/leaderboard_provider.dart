import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTopArtists({
    required String field,
    required int limit,
    String? timeframe,
  }) async {
    try {
      if (timeframe != null && timeframe != 'all_time') {
        final response = await _supabase
            .from('leaderboard_rankings')
            .select('*, users(*)')
            .eq('timeframe', timeframe)
            .eq('field', field)
            .order('score', ascending: false)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('is_active', true)
          .order(field, ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserRank(String userId, String field) async {
    try {
      return await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordUserRankHistory(String userId, Map<String, dynamic> rankData) async {
    try {
      await _supabase.from('leaderboard_rankings').insert({
        ...rankData,
        'user_id': userId,
      });
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> getRegionalLeaderboard(String region, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('location', region)
          .eq('is_active', true)
          .order('likes_count', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSeasonalRankings(String seasonId, {int limit = 100}) async {
    try {
      final response = await _supabase
          .from('leaderboard_rankings')
          .select('*, users(*)')
          .eq('timeframe', seasonId)
          .order('score', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSeasonalScore(String seasonId, String userId, int points) async {
    try {
      final existing = await _supabase
          .from('leaderboard_rankings')
          .select('score')
          .eq('timeframe', seasonId)
          .eq('user_id', userId)
          .maybeSingle();

      final currentScore = (existing?['score'] as int?) ?? 0;
      await _supabase.from('leaderboard_rankings').upsert({
        'user_id': userId,
        'timeframe': seasonId,
        'field': 'seasonal_score',
        'score': currentScore + points,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHallOfFame() async {
    try {
      final response = await _supabase
          .from('hall_of_fame')
          .select('*, users(*)')
          .order('year', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> nominateToHallOfFame(String userId, String reason) async {
    try {
      await _supabase.from('hall_of_fame').insert({
        'user_id': userId,
        'reason': reason,
        'year': DateTime.now().year,
      });
    } catch (e) {
      rethrow;
    }
  }
}
