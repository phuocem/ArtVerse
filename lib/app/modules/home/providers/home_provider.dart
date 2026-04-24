import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/services/database_service.dart';
import 'package:get/get.dart';

class HomeProvider extends GetConnect {
  final DatabaseService _db = Get.find<DatabaseService>();
  final SupabaseClient _supabase = Supabase.instance.client;

  Box<DrawProjectModel> get projectBox => _db.drawProjectBox;

  Future<void> saveProject(DrawProjectModel project) async {
    await projectBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await projectBox.delete(id);
  }

  List<DrawProjectModel> getAllProjects() {
    return projectBox.values.toList();
  }

  Future<List<Map<String, dynamic>>> getTopArtists() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('is_active', true)
          .order('followers_count', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProjectFile(String userId, String projectId, String projectJson) async {
    final projectBytes = utf8.encode(projectJson);
    final storagePath = '$userId/$projectId/project.json';
    
    await _supabase.storage
        .from('posts')
        .uploadBinary(
          storagePath,
          Uint8List.fromList(projectBytes),
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'application/json',
          ),
        );
  }

  String getProjectFileUrl(String userId, String projectId) {
    return _supabase.storage.from('posts').getPublicUrl('$userId/$projectId/project.json');
  }

  Future<void> saveCloudDraftMetadata(String userId, String projectId, String name, String fileUrl) async {
    await _supabase.from('cloud_drafts').upsert({
      'user_id': userId,
      'project_id': projectId,
      'name': name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'project_file_url': fileUrl,
    });
  }

  Future<List<Map<String, dynamic>>> fetchCloudDrafts(String userId) async {
    final response = await _supabase
        .from('cloud_drafts')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<http.Response> downloadProjectFile(String url) async {
    return await http.get(Uri.parse(url));
  }
}
