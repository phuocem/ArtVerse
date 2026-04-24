import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getActiveChallenges() async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .gt('end_at', DateTime.now().toUtc().toIso8601String())
          .order('end_at')
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyPrompt() async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .eq('is_daily', true)
          .limit(1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinChallenge(String userId, String challengeId) async {
    try {
      await _supabase.from('challenge_participants').insert({
        'challenge_id': challengeId,
        'user_id': userId,
        'status': 'active',
      });

      
      final challenge = await _supabase
          .from('challenges')
          .select('participant_count')
          .eq('id', challengeId)
          .single();
      await _supabase.from('challenges').update({
        'participant_count': ((challenge['participant_count'] as int?) ?? 0) + 1,
      }).eq('id', challengeId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitChallengeEntry({
    required String challengeId,
    required String userId,
    required Map<String, dynamic> entryData,
  }) async {
    try {
      await _supabase.from('challenge_submissions').upsert({
        'challenge_id': challengeId,
        'user_id': userId,
        'data': entryData,
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getChallengeSubmissions(String challengeId) async {
    try {
      final response = await _supabase
          .from('challenge_submissions')
          .select()
          .eq('challenge_id', challengeId)
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> voteForSubmission({
    required String challengeId,
    required String submissionId,
    required String userId,
  }) async {
    try {
      await _supabase.from('challenge_votes').insert({
        'challenge_id': challengeId,
        'submission_id': submissionId,
        'user_id': userId,
      });

      
      final submission = await _supabase
          .from('challenge_submissions')
          .select('vote_count')
          .eq('id', submissionId)
          .single();
      await _supabase.from('challenge_submissions').update({
        'vote_count': ((submission['vote_count'] as int?) ?? 0) + 1,
      }).eq('id', submissionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateChallengeStats(String challengeId, Map<String, dynamic> stats) async {
    try {
      await _supabase.from('challenges').update({
        ...stats,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', challengeId);
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> getChallengesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      
      
      await _supabase.from('challenges').delete().eq('id', challengeId);
    } catch (e) {
      rethrow;
    }
  }
}
