import 'dart:convert';
import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/models/user_model.dart';
import '../providers/home_provider.dart';

class HomeRepository {
  final HomeProvider _provider;
  HomeRepository(this._provider);

  Future<List<UserModel>> getLeaderboard() async {
    final data = await _provider.getTopArtists();
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  List<DrawProjectModel> getAllProjects() {
    return _provider.getAllProjects();
  }

  Future<void> saveProject(DrawProjectModel project) async {
    await _provider.saveProject(project);
  }

  Future<void> deleteProject(String id) async {
    await _provider.deleteProject(id);
  }

  Future<void> syncProjectToCloud(String userId, DrawProjectModel project) async {
    final jsonStr = jsonEncode(project.toJson());
    await _provider.uploadProjectFile(userId, project.id, jsonStr);
    final fileUrl = _provider.getProjectFileUrl(userId, project.id);
    await _provider.saveCloudDraftMetadata(userId, project.id, project.name, fileUrl);
  }

  Future<List<Map<String, dynamic>>> getCloudDrafts(String userId) async {
    return await _provider.fetchCloudDrafts(userId);
  }

  Future<DrawProjectModel?> downloadProject(String url) async {
    final response = await _provider.downloadProjectFile(url);
    if (response.statusCode == 200) {
      return DrawProjectModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
