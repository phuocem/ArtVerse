import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/user_model.dart';

class SearchProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .limit(limit);
      return (response as List).map((doc) => UserModel.fromJson(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> searchPosts(String query, {String? category, int limit = 20}) async {
    try {
      var request = _supabase
          .from('posts')
          .select()
          .eq('is_deleted', false)
          .ilike('name', '%$query%');

      if (category != null && category != 'all') {
        request = request.eq('category', category);
      }

      final response = await request.limit(limit);
      return (response as List).map((doc) => PostModel.fromJson(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ResourceModel>> searchResources(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('resources')
          .select()
          .eq('is_deleted', false)
          .ilike('name', '%$query%')
          .limit(limit);
      return (response as List).map((doc) => ResourceModel.fromJson(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getSearchHistory(String userId) async {
    try {
      final response = await _supabase
          .from('user_searches')
          .select('query')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(20);
      return (response as List).map((e) => e['query'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToSearchHistory(String userId, String query) async {
    try {
      await _supabase.from('user_searches').insert({
        'user_id': userId,
        'query': query,
      });
    } catch (e) {
    }
  }

  Future<void> clearHistory(String userId) async {
    try {
      await _supabase
          .from('user_searches')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getTrendingKeywords() async {
    try {
      final response = await _supabase
          .from('trending_searches')
          .select('keyword')
          .order('count', ascending: false)
          .limit(10);
      return (response as List).map((doc) => doc['keyword'] as String).toList();
    } catch (e) {
      return ['Digital Art', 'Cyberpunk', 'Pink Sanctuary', 'Tutorial'];
    }
  }

  Future<void> recordSearchMetric(String keyword) async {
    try {
      await _supabase.from('trending_searches').upsert({
        'keyword': keyword,
        'count': 1,
        'last_hit': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
    }
  }

  Future<List<PostModel>> searchByTags(List<String> tags, {int limit = 15}) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('is_deleted', false)
          .contains('tags', tags)
          .limit(limit);
      return (response as List).map((doc) => PostModel.fromJson(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
