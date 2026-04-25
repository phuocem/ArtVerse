import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioController extends GetxController {
  final PortfolioRepository repository;
  final profileController = Get.find<ProfileController>();

  PortfolioController({required this.repository});

  final projects = <PostModel>[].obs;
  final collections = <Map<String, dynamic>>[].obs;
  final portfolioStats = <String, int>{}.obs;
  final isLoading = true.obs;
  final filterStatus = (-1).obs;
  final completionScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      await Future.wait([
        _loadProjects(userId),
        _loadCollections(userId),
        _loadStats(userId),
      ]);
      _calculateCompletion();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProjects(String userId) async {
    try {
      final list = await repository.getUserProjects(userId);
      projects.assignAll(list);
    } catch (e) {
    }
  }

  Future<void> _loadCollections(String userId) async {
    try {
      final list = await repository.fetchCollections(userId);
      collections.assignAll(list);
    } catch (e) {
    }
  }

  Future<void> _loadStats(String userId) async {
    try {
      final stats = await repository.fetchPortfolioStats(userId);
      portfolioStats.assignAll(stats);
    } catch (e) {
    }
  }

  void _calculateCompletion() {
    completionScore.value = repository.calculatePortfolioCompletion(projects);
  }

  Future<void> refreshPortfolio() async {
    await _loadAllData();
  }

  void setFilter(int status) async {
    filterStatus.value = status;
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;

    if (status == -1) {
      await _loadProjects(userId);
    } else {
      isLoading.value = true;
      final filtered = await repository.getFilteredProjects(userId, status);
      projects.assignAll(filtered);
      isLoading.value = false;
    }
  }

  Future<void> updateProject(String projectId, {String? name, String? desc}) async {
    try {
      await repository.updateProjectDetails(projectId, name: name, desc: desc);
      await refreshPortfolio();
      _showPinkSnackbar('Updated 🌸', 'Project details updated 💗');
    } catch (e) {
      _showErrorSnackbar('Error', 'Could not update project');
    }
  }

  Future<void> changeVisibility(String projectId, bool isPublic) async {
    try {
      await repository.setProjectVisibility(projectId, isPublic);
      await refreshPortfolio();
      _showPinkSnackbar('Success 🌸', 'Visibility updated 💗');
    } catch (e) {
      _showErrorSnackbar('Error', 'Could not change visibility');
    }
  }

  Future<void> createCollection(String name, String? desc) async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;

    try {
      await repository.createNewUserCollection(userId, name, desc);
      await _loadCollections(userId);
      _showPinkSnackbar('Created 🌸', 'New collection added 💗');
    } catch (e) {
      _showErrorSnackbar('Error', 'Could not create collection');
    }
  }

  void openProject(PostModel post) {
    if (post.isVideo) {
      Get.toNamed('/watch/${post.id}');
    } else {
      Get.toNamed('/view/${post.id}');
    }
  }

  void _showPinkSnackbar(String title, String message) {
    Get.snackbar(
      "🌸 $title 💗",
      message,
      backgroundColor: const Color(0xFFFF69B4).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      "🌸 $title 💗",
      message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
    );
  }

  Color get primaryColor => const Color(0xFFFF69B4);
}
