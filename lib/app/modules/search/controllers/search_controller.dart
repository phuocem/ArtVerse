import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/search_repository.dart';

class SearchController extends GetxController {
  final SearchRepository repository;
  final searchController = TextEditingController();
  final searchText = ''.obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs;

  SearchController({required this.repository});

  final userResults = <UserModel>[].obs;
  final postResults = <PostModel>[].obs;
  final resourceResults = <ResourceModel>[].obs;
  final history = <String>[].obs;
  final trending = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    try {
      if (userId != null) {
        final list = await repository.fetchUserSearchHistory(userId);
        history.assignAll(list);
      }
      final topics = await repository.fetchTrendingTopics();
      trending.assignAll(topics);
    } catch (e) {
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
    if (value.length >= 2) {
      searchAll(value);
    } else {
      _clearResults();
    }
  }

  Future<void> searchAll(String query) async {
    if (query.trim().isEmpty) return;
    isLoading.value = true;

    try {
      final results = await repository.searchUnified(query);

      userResults.assignAll(results['users'] as List<UserModel>);
      postResults.assignAll(results['posts'] as List<PostModel>);
      resourceResults.assignAll(results['resources'] as List<ResourceModel>);

      final userId = Get.find<ProfileController>().currentUser.value?.id;
      if (userId != null) {
        await repository.saveSearchQuery(userId, query);
        await _loadInitialData();
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void selectTrending(String topic) {
    searchController.text = topic;
    updateSearch(topic);
  }

  void clearSearchHistory() async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;

    try {
      await repository.removeSearchHistory(userId);
      history.clear();
      _showPinkSnackbar('Cleared 🌸', 'Search history removed 💗');
    } catch (e) {
      _showErrorSnackbar('Error', 'Could not clear history');
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    if (searchText.value.isNotEmpty) {
      searchAll(searchText.value);
    }
  }

  void _clearResults() {
    userResults.clear();
    postResults.clear();
    resourceResults.clear();
  }

  String getSearchAura() {
    return repository.generateSearchAura(searchText.value);
  }

  void _showPinkSnackbar(String title, String message) {
    Get.snackbar(
      "🌸 $title 💗",
      message,
      backgroundColor: const Color(0xFFFF69B4).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
      borderRadius: 20,
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
      borderRadius: 20,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
