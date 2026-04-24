import 'package:artverse/app/data/models/post_model.dart';
import 'package:artverse/app/modules/dashboard/providers/dashboard_provider.dart';

class DashboardRepository {
  final DashboardProvider _provider;

  DashboardRepository(this._provider);

  Future<List<PostModel>> getUserPosts(String userId) async {
    final snap = await _provider.getUserPosts(userId);
    return snap.map((json) {
      return PostModel.fromJson(json);
    }).toList();
  }

  Future<List<PostModel>> getTrendingPosts() async {
    final snap = await _provider.getTrendingPosts();
    return snap.map((json) {
      return PostModel.fromJson(json);
    }).toList();
  }
}
