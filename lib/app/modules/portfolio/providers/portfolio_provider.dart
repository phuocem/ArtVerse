import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserProjects(String userId) async {
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

  Future<List<Map<String, dynamic>>> getProjectsByStatus(String userId, int status) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('status', status)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProjectMetadata(String projectId, Map<String, dynamic> metadata) async {
    try {
      await _supabase.from('posts').update({
        ...metadata,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', projectId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserCollections(String userId) async {
    try {
      final response = await _supabase
          .from('collections')
          .select()
          .eq('user_id', userId)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCollection(String userId, Map<String, dynamic> collectionData) async {
    try {
      await _supabase.from('collections').insert({
        ...collectionData,
        'user_id': userId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCollection(String userId, String collectionId) async {
    try {
      await _supabase
          .from('collections')
          .delete()
          .eq('id', collectionId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPortfolioStats(String userId) async {
    try {
      return await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleProjectPrivacy(String projectId, bool isPublic) async {
    try {
      await _supabase.from('posts').update({
        'status': isPublic ? 1 : 0,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', projectId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProjectToCollection(String userId, String collectionId, String projectId) async {
    try {
      
      final collection = await _supabase
          .from('collections')
          .select('project_ids')
          .eq('id', collectionId)
          .eq('user_id', userId)
          .single();
      final currentIds = List<String>.from(collection['project_ids'] ?? []);
      if (!currentIds.contains(projectId)) {
        currentIds.add(projectId);
        await _supabase.from('collections').update({
          'project_ids': currentIds,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', collectionId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeProjectFromCollection(String userId, String collectionId, String projectId) async {
    try {
      final collection = await _supabase
          .from('collections')
          .select('project_ids')
          .eq('id', collectionId)
          .eq('user_id', userId)
          .single();
      final currentIds = List<String>.from(collection['project_ids'] ?? []);
      currentIds.remove(projectId);
      await _supabase.from('collections').update({
        'project_ids': currentIds,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', collectionId);
    } catch (e) {
      rethrow;
    }
  }
}
