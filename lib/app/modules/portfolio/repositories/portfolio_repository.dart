import '../../../data/models/post_model.dart';
import '../providers/portfolio_provider.dart';

class PortfolioRepository {
  final PortfolioProvider provider;

  PortfolioRepository({required this.provider});

  Future<List<PostModel>> getUserProjects(String userId) async {
    try {
      final snap = await provider.getUserProjects(userId);
      return snap.map((doc) => PostModel.fromJson(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getFilteredProjects(String userId, int status) async {
    try {
      final snap = await provider.getProjectsByStatus(userId, status);
      return snap.map((doc) => PostModel.fromJson(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateProjectDetails(String projectId, {String? name, String? desc, List<String>? tags}) async {
    try {
      final metadata = <String, dynamic>{};
      if (name != null) metadata['name'] = name;
      if (desc != null) metadata['description'] = desc;
      if (tags != null) metadata['tags'] = tags;

      if (metadata.isEmpty) return;
      await provider.updateProjectMetadata(projectId, metadata);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, int>> fetchPortfolioStats(String userId) async {
    try {
      final doc = await provider.getPortfolioStats(userId);
      if (doc == null) {
        return {'total_projects': 0, 'total_views': 0, 'total_likes': 0};
      }
      return {
        'total_projects': (doc['total_projects'] ?? 0) as int,
        'total_views': (doc['total_views'] ?? 0) as int,
        'total_likes': (doc['total_likes'] ?? 0) as int,
      };
    } catch (e) {
      return {'total_projects': 0, 'total_views': 0, 'total_likes': 0};
    }
  }

  Future<void> createNewUserCollection(String userId, String name, String? description) async {
    try {
      if (name.trim().isEmpty) throw Exception('Collection name cannot be empty');
      await provider.createCollection(userId, {
        'name': name,
        'description': description ?? '',
        'projectIds': [],
        'isPublic': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addWorkToCollection(String userId, String collectionId, String projectId) async {
    try {
      await provider.addProjectToCollection(userId, collectionId, projectId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setProjectVisibility(String projectId, bool isPublic) async {
    try {
      await provider.toggleProjectPrivacy(projectId, isPublic);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCollections(String userId) async {
    try {
      final snapshot = await provider.getUserCollections(userId);
      return snapshot;
    } catch (e) {
      return [];
    }
  }

  Future<void> removeCollectionPermanently(String userId, String collectionId) async {
    try {
      await provider.deleteCollection(userId, collectionId);
    } catch (e) {
      rethrow;
    }
  }

  double calculatePortfolioCompletion(List<PostModel> projects) {
    if (projects.isEmpty) return 0.0;
    final int completedCount = projects.where((p) => p.name.isNotEmpty && p.thumbnail.isNotEmpty).length;
    return (completedCount / projects.length).clamp(0.0, 1.0);
  }
}
