import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/models/draw/frame_model.dart';
import '../../../data/services/database_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../data/services/app_globals.dart';
import '../../../data/models/user_model.dart';
import '../repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;
  HomeController(this._repository);

  final leaderboardUsers = <UserModel>[].obs;
  final projects = <DrawProjectModel>[].obs;
  final filteredProjects = <DrawProjectModel>[].obs;
  final fps = 12.obs;
  final fpsOptions = [6, 12, 24];
  final onionSkin = 1.obs;
  final onionSkinOptions = [0, 1, 2, 3];
  final searchQuery = ''.obs;
  final filterType = 'all'.obs;
  final currentHomeTab = 0.obs;
  final cloudDrafts = <Map<String, dynamic>>[].obs;
  final isCloudView = false.obs;
  final isLoadingCloud = false.obs;
  final canvasBackgroundColor = Colors.white.obs;
  final isSidebarOpen = true.obs;

  void toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value;
  }

  final bannerIndex = 0.obs;
  late final PageController bannerPageController;
  final bannerImages = const [
    'assets/images/banners/hero_banner_bg.png',
    'assets/images/banners/hero_banner_2.png',
    'assets/images/banners/hero_banner_3.png',
    'assets/images/banners/hero_banner_4.png',
    'assets/images/banners/hero_banner_5.png',
    'assets/images/banners/hero_banner_6.png',
    'assets/images/banners/hero_banner_7.png',
  ];
  Timer? _bannerTimer;

  late final Box<DrawProjectModel> _projectBox;
  Worker? _searchWorker;
  Worker? _filterWorker;

  @override
  void onInit() {
    super.onInit();
    _projectBox = Get.find<DatabaseService>().drawProjectBox;
    loadProjects();
    fetchLeaderboard();
    _searchWorker = ever(searchQuery, (_) => applyFilter());
    _filterWorker = ever(filterType, (_) => applyFilter());
    
    
    bannerPageController = PageController(initialPage: bannerIndex.value);
    
    
    _bannerTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (bannerImages.isEmpty) return;
      if (bannerPageController.hasClients) {
        final next = (bannerIndex.value + 1) % bannerImages.length;
        bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> fetchLeaderboard() async {
    try {
      final list = await _repository.getLeaderboard();
      leaderboardUsers.assignAll(list);
    } catch (e) {
      if (kDebugMode) debugPrint("Fetch Leaderboard Error: $e");
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    _filterWorker?.dispose();
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  void loadProjects() {
    final loaded = _projectBox.values.toList();
    for (final project in loaded) {
      if (project.frames.isEmpty) {
        project.frames.add(FrameModel());
        _projectBox.put(project.id, project);
      }
    }
    projects.assignAll(loaded);
    applyFilter();
  }

  void applyFilter() {
    final query = searchQuery.value.toLowerCase();
    final type = filterType.value;
    filteredProjects.assignAll(
      projects.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final visibleFrames = p.frames.where((f) => !f.isHidden).length;
        final frameCountMatch = visibleFrames.toString().contains(query);
        final matchesSearch = query.isEmpty || nameMatch || frameCountMatch;
        bool matchesFilter = true;
        if (type == 'art') {
          matchesFilter = p.isAnimation == false;
        } else if (type == 'anim') {
          matchesFilter = p.isAnimation == true;
        } else if (type == 'starred') {
          matchesFilter = p.isFavorite == true;
        }
        return matchesSearch && matchesFilter;
      }).toList(),
    );
  }

  void addProject(DrawProjectModel project) {
    _projectBox.put(project.id, project);
    projects.add(project);
    applyFilter();
  }

  void deleteProject(String id) {
    _projectBox.delete(id);
    projects.removeWhere((p) => p.id == id);
    applyFilter();
  }

  void toggleFavorite(String id) {
    final index = projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      final project = projects[index];
      project.isFavorite = !project.isFavorite;
      _projectBox.put(id, project);
      projects.refresh();
    }
  }

  Future<void> syncToCloud(DrawProjectModel project) async {
    final profileController = Get.find<ProfileController>();
    final userId = profileController.currentUser.value?.id;
    if (userId == null) {
      safeSnackbar(
        'Login Required',
        'Please login to sync projects to cloud',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFC2C1FF)),
        ),
        barrierDismissible: false,
      );
      await _repository.syncProjectToCloud(userId, project);
      Get.back();
      safeSnackbar('Success', 'Project synced to cloud successfully!');
      if (isCloudView.value) fetchCloudDrafts();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      safeSnackbar(
        'Error',
        'Failed to sync: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchCloudDrafts() async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;
    try {
      isLoadingCloud.value = true;
      final drafts = await _repository.getCloudDrafts(userId);
      drafts.sort((a, b) {
        final dateA = DateTime.tryParse(a['updated_at'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['updated_at'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });
      cloudDrafts.assignAll(drafts);
    } catch (e) {
      if (kDebugMode) debugPrint("Error fetching cloud drafts: $e");
    } finally {
      isLoadingCloud.value = false;
    }
  }

  Future<void> restoreProject(Map<String, dynamic> cloudData) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFC2C1FF)),
        ),
        barrierDismissible: false,
      );
      final url = cloudData['project_file_url'] as String;
      final project = await _repository.downloadProject(url);
      if (project != null) {
        await _repository.saveProject(project);
        loadProjects();
        Get.back();
        safeSnackbar(
          "Restored",
          "Project '${project.name}' is now available locally.",
        );
      } else {
        if (Get.isDialogOpen ?? false) Get.back();
        safeSnackbar("Error", "Could not download project file.");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      safeSnackbar("Error", "Restore failed: $e");
    }
  }

  void toggleViewMode(bool cloud) {
    isCloudView.value = cloud;
    if (cloud) {
      fetchCloudDrafts();
    }
  }

  void safeSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
  }) {
    snackbarKey.currentState?.hideCurrentSnackBar();
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
