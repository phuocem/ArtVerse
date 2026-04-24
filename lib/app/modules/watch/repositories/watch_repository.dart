import '../../../data/models/post_model.dart';
import '../providers/watch_provider.dart';

class WatchRepository {
  final WatchProvider provider;

  WatchRepository({required this.provider});

  Future<PostModel?> fetchVideoData(String id) async {
    try {
      final doc = await provider.getVideo(id);
      if (doc == null) return null;
      return PostModel.fromJson(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateViews(String id, int currentViews) async {
    try {
      await provider.incrementViews(id, currentViews);
    } catch (e) {
    }
  }

  Future<void> trackUserWatchHistory(String userId, String postId, int secondsWatched) async {
    try {
      if (secondsWatched < 1) return;
      await provider.recordWatchTime(postId, userId, secondsWatched);
    } catch (e) {
    }
  }

  Future<List<PostModel>> getRecommendedVideos(String category) async {
    try {
      final snapshot = await provider.getRelatedVideos(category);
      return snapshot.map((doc) => PostModel.fromJson(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> getUserLikeStatus(String postId, String userId) async {
    try {
      return await provider.checkUserLike(postId, userId);
    } catch (e) {
      return false;
    }
  }

  Future<void> handleToggleLike({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  }) async {
    try {
      if (isCurrentlyLiked) {
        await provider.removeLike(postId, userId);
      } else {
        await provider.addLike(postId, userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchVideoComments(String postId) async {
    try {
      final snapshot = await provider.getComments(postId);
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitNewComment({
    required String postId,
    required Map<String, dynamic> commentData,
  }) async {
    try {
      if (commentData['content'] == null || commentData['content'].toString().trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      await provider.addComment(postId, commentData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addVideoToUserPlaylist({
    required String userId,
    required String postId,
    required String playlistId,
  }) async {
    try {
      await provider.saveToPlaylist(userId, postId, playlistId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportVideoIssue(String postId, String userId, String reason) async {
    try {
    } catch (e) {
    }
  }
}
