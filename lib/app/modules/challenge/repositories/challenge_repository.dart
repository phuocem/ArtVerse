import '../../../data/models/challenge_model.dart';
import '../providers/challenge_provider.dart';

class ChallengeRepository {
  final ChallengeProvider _provider;

  ChallengeRepository(this._provider);

  Future<List<ChallengeModel>> fetchActiveChallenges() async {
    try {
      final snap = await _provider.getActiveChallenges();
      return snap
          .map((data) => ChallengeModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ChallengeModel?> fetchDailyPrompt() async {
    try {
      final snap = await _provider.getDailyPrompt();
      if (snap.isEmpty) return null;
      return ChallengeModel.fromJson(snap.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerForChallenge(String userId, String challengeId) async {
    try {
      await _provider.joinChallenge(userId, challengeId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitEntry({
    required String challengeId,
    required String userId,
    required String contentUrl,
    required String title,
  }) async {
    try {
      if (contentUrl.isEmpty) throw Exception('Content URL is required for submission');

      await _provider.submitChallengeEntry(
        challengeId: challengeId,
        userId: userId,
        entryData: {
          'content_url': contentUrl,
          'title': title,
          'votes': 0,
          'status': 'submitted',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubmissions(String challengeId) async {
    try {
      final snapshot = await _provider.getChallengeSubmissions(challengeId);
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> castVote({
    required String challengeId,
    required String submissionId,
    required String userId,
  }) async {
    try {
      await _provider.voteForSubmission(
        challengeId: challengeId,
        submissionId: submissionId,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  String getChallengeStatus(ChallengeModel challenge) {
    final now = DateTime.now();
    if (now.isAfter(challenge.endAt)) return '🌸 Completed 💗';
    if (now.isBefore(challenge.startAt)) return '🌸 Upcoming 💗';
    return '🌸 Active 💗';
  }

  bool isEntryDeadlineNear(ChallengeModel challenge) {
    final now = DateTime.now();
    final difference = challenge.endAt.difference(now).inHours;
    return difference > 0 && difference < 24;
  }

  Future<List<ChallengeModel>> fetchChallengesByTag(String tag) async {
    try {
      final snap = await _provider.getChallengesByCategory(tag);
      return snap
          .map((data) => ChallengeModel.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> removeExpiredChallenge(String id) async {
    try {
      await _provider.deleteChallenge(id);
    } catch (e) {
    }
  }

  Future<void> incrementParticipantMetric(String challengeId, int currentCount) async {
    try {
      await _provider.updateChallengeStats(challengeId, {
        'participant_count': currentCount + 1,
      });
    } catch (e) {
    }
  }
}
