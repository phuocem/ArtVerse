import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
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

  Future<List<Map<String, dynamic>>> getTrendingPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('status', 1)
          .eq('is_deleted', false)
          .order('views', ascending: false)
          .limit(5);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUserReceivedLikes(String userId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('user_id', userId);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
