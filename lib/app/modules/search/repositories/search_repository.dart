import '../../../data/models/post_model.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/user_model.dart';
import '../providers/search_provider.dart';

class SearchRepository {
  final SearchProvider provider;

  SearchRepository({required this.provider});

  Future<List<UserModel>> searchUsers(String query, {int limit = 15}) async {
    try {
      if (query.trim().isEmpty) return [];
      return await provider.searchUsers(query, limit: limit);
    } catch (e) {
      return [];
    }
  }

  Future<List<PostModel>> searchPosts(String query, {String? category, int limit = 30}) async {
    try {
      if (query.trim().isEmpty) return [];
      return await provider.searchPosts(query, category: category, limit: limit);
    } catch (e) {
      return [];
    }
  }

  Future<List<ResourceModel>> searchResources(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      return await provider.searchResources(query);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, List<dynamic>>> searchUnified(String query) async {
    try {
      if (query.trim().isEmpty) return {'users': [], 'posts': [], 'resources': []};

      final results = await Future.wait([
        provider.searchUsers(query, limit: 5),
        provider.searchPosts(query, limit: 10),
        provider.searchResources(query, limit: 5),
      ]);

      return {
        'users': results[0],
        'posts': results[1],
        'resources': results[2],
      };
    } catch (e) {
      return {'users': [], 'posts': [], 'resources': []};
    }
  }

  Future<List<String>> fetchUserSearchHistory(String userId) async {
    try {
      if (userId.isEmpty) return [];
      return await provider.getSearchHistory(userId);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSearchQuery(String userId, String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return;

      await provider.addToSearchHistory(userId, cleanQuery);
      await provider.recordSearchMetric(cleanQuery);
    } catch (e) {
    }
  }

  Future<void> removeSearchHistory(String userId) async {
    try {
      await provider.clearHistory(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchTrendingTopics() async {
    try {
      return await provider.getTrendingKeywords();
    } catch (e) {
      return ['Digital Art', 'Tutorial', 'Sanctuary'];
    }
  }

  Future<List<PostModel>> searchByTopicTags(String tag) async {
    try {
      if (tag.isEmpty) return [];
      return await provider.searchByTags([tag]);
    } catch (e) {
      return [];
    }
  }

  List<PostModel> sortResultsByPopularity(List<PostModel> results) {
    if (results.isEmpty) return [];
    results.sort((a, b) => (b.views + b.likesCount).compareTo(a.views + a.likesCount));
    return results;
  }

  List<String> extractKeywords(String input) {
    if (input.isEmpty) return [];
    return input.toLowerCase().split(' ').where((s) => s.length > 2).toList();
  }

  String generateSearchAura(String query) {
    if (query.isEmpty) return '🌸 Enter search terms... 💗';
    return '🌸 Searching for "$query" 💗';
  }
}
