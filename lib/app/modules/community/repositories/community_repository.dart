
import '../../../data/models/post_model.dart';
import '../providers/community_provider.dart';

class CommunityRepository {
  final CommunityProvider provider;

  CommunityRepository({required this.provider});

  Future<List<Map<String, dynamic>>> fetchPosts({
    required int limit,
    int offset = 0,
    String? category,
    String? searchQuery,
  }) async {
    try {
      return await provider.getPosts(
        limit: limit,
        offset: offset,
        category: category,
        searchQuery: searchQuery,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel?> getPostDetail(String postId) async {
    try {
      final data = await provider.getPostById(postId);
      if (data == null) return null;
      
      return PostModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordView(String postId) async {
    try {
      await provider.incrementView(postId);
    } catch (e) {
    }
  }

  Future<void> handleToggleLike({
    required String postId,
    required String userId,
    required bool isLike,
  }) async {
    try {
      await provider.toggleLike(
        postId: postId,
        userId: userId,
        isLike: isLike,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    try {
      final snapshot = await provider.getComments(postId);
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> postNewComment({
    required String postId,
    required Map<String, dynamic> commentData,
  }) async {
    try {
      if (commentData['content'] == null || commentData['content'].toString().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }

      await provider.addComment(
        postId: postId,
        commentData: commentData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> fetchUsersPosts(String userId) async {
    try {
      final snapshot = await provider.getPostsByUserId(userId);
      return snapshot.map((data) {
        return PostModel.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deactivatePost(String postId) async {
    try {
      await provider.updatePostStatus(postId, 0);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> permanentlyDeletePost(String postId) async {
    try {
      await provider.deletePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePostVisibility(String postId, int status) async {
    try {
      if (status < 0 || status > 2) throw Exception('Invalid status code');
      await provider.updatePostStatus(postId, status);
    } catch (e) {
      rethrow;
    }
  }
}
