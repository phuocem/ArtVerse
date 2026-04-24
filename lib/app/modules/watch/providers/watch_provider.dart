import 'package:supabase_flutter/supabase_flutter.dart';

class WatchProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getVideo(String id) async {
    try {
      return await _supabase
          .from('posts')
          .select()
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementViews(String id, int currentViews) async {
    try {
      await _supabase.from('posts').update({
        'views': currentViews + 1,
        'last_watched_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
    }
  }

  Future<void> recordWatchTime(String id, String userId, int seconds) async {
    try {
      
      final existing = await _supabase
          .from('watch_history')
          .select('watch_time_seconds')
          .eq('user_id', userId)
          .eq('post_id', id)
          .maybeSingle();

      final currentSeconds = (existing?['watch_time_seconds'] as int?) ?? 0;
      await _supabase.from('watch_history').upsert({
        'user_id': userId,
        'post_id': id,
        'watch_time_seconds': currentSeconds + seconds,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> getRelatedVideos(String category, {int limit = 6}) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('category', category)
          .eq('status', 1)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLikes(String postId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUserLike(String postId, String userId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> addLike(String postId, String userId) async {
    try {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'post_id': postId,
        'post_type': 'post',
      });
      
      final post = await _supabase.from('posts').select('likes_count').eq('id', postId).single();
      await _supabase.from('posts').update({
        'likes_count': ((post['likes_count'] as int?) ?? 0) + 1,
      }).eq('id', postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeLike(String postId, String userId) async {
    try {
      await _supabase
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      
      final post = await _supabase.from('posts').select('likes_count').eq('id', postId).single();
      await _supabase.from('posts').update({
        'likes_count': ((post['likes_count'] as int?) ?? 1) - 1,
      }).eq('id', postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(String postId, Map<String, dynamic> commentData) async {
    try {
      await _supabase.from('comments').insert({
        ...commentData,
        'post_id': postId,
        'post_type': 'post',
      });
      
      final post = await _supabase.from('posts').select('comments_count').eq('id', postId).single();
      await _supabase.from('posts').update({
        'comments_count': ((post['comments_count'] as int?) ?? 0) + 1,
      }).eq('id', postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveToPlaylist(String userId, String postId, String playlistId) async {
    try {
      
      await _supabase.from('watch_history').upsert({
        'user_id': userId,
        'post_id': postId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
