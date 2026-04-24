import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPosts({
    required int limit,
    int? offset,
    String? category,
    String? searchQuery,
  }) async {
    try {
      dynamic query = _supabase
          .from('posts')
          .select()
          .eq('status', 1)
          .eq('is_deleted', false);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      if (category == 'trending') {
        query = query.order('views', ascending: false);
      } else {
        query = query.order('created_at', ascending: false);
      }

      if (offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPostById(String id) async {
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

  Future<void> incrementView(String id) async {
    try {
      final post = await _supabase.from('posts').select('views').eq('id', id).single();
      await _supabase.from('posts').update({
        'views': ((post['views'] as int?) ?? 0) + 1,
      }).eq('id', id);
    } catch (e) {
    }
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isLike,
  }) async {
    try {
      if (isLike) {
        await _supabase.from('likes').insert({
          'user_id': userId,
          'post_id': postId,
          'post_type': 'post',
        });
        final post = await _supabase.from('posts').select('likes_count').eq('id', postId).single();
        await _supabase.from('posts').update({
          'likes_count': ((post['likes_count'] as int?) ?? 0) + 1,
        }).eq('id', postId);
      } else {
        await _supabase.from('likes').delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        final post = await _supabase.from('posts').select('likes_count').eq('id', postId).single();
        await _supabase.from('posts').update({
          'likes_count': ((post['likes_count'] as int?) ?? 1) - 1,
        }).eq('id', postId);
      }
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

  Future<void> addComment({
    required String postId,
    required Map<String, dynamic> commentData,
  }) async {
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

  Future<void> updatePostStatus(String id, int status) async {
    try {
      await _supabase.from('posts').update({
        'status': status,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPostsByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      
      await _supabase.from('posts').update({
        'is_deleted': true,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
