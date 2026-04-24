import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/models/draw/frame_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../home/repositories/home_repository.dart';
import '../repositories/challenge_repository.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/models/user_model.dart';

class ChallengeController extends GetxController {
  final ChallengeRepository repository;
  final HomeRepository homeRepository;

  ChallengeController({
    required this.repository,
    required this.homeRepository,
  });

  final activeChallenges = <ChallengeModel>[].obs;
  final dailyPrompt = Rxn<ChallengeModel>();
  final leaderboardUsers = <UserModel>[].obs;
  final submissions = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchChallenges(),
        fetchLeaderboard(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChallenges() async {
    try {
      final list = await repository.fetchActiveChallenges();
      activeChallenges.assignAll(list);
      dailyPrompt.value = await repository.fetchDailyPrompt() ?? 
        (list.isNotEmpty ? list.first : null);
    } catch (e) {
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      final list = await homeRepository.getLeaderboard();
      leaderboardUsers.assignAll(list);
    } catch (e) {
    }
  }

  Future<void> fetchSubmissions(String challengeId) async {
    try {
      final list = await repository.fetchSubmissions(challengeId);
      submissions.assignAll(list);
    } catch (e) {
    }
  }

  void acceptChallenge(ChallengeModel challenge) async {
    final profileController = Get.find<ProfileController>();
    final userId = profileController.currentUser.value?.id;
    
    if (userId == null) {
      _showPinkToast("🌸 LOGIN REQUIRED 💗", "Please log in to participate.");
      return;
    }

    try {
      await repository.registerForChallenge(userId, challenge.id);
      
      final homeController = Get.find<HomeController>();
      final userName = profileController.currentUser.value?.name ?? 'Artist';
      
      final newProject = DrawProjectModel(
        id: const Uuid().v4(),
        name: "${challenge.title} - $userName",
        updatedAt: DateTime.now(),
        frames: [FrameModel()],
      );

      homeController.addProject(newProject);
      Get.toNamed<void>('/draw', arguments: {'projectId': newProject.id});

      _showPinkToast("🌸 CHALLENGE ACCEPTED 💗", "Good luck, $userName!");
    } catch (e) {
    }
  }

  Future<void> vote(String challengeId, String submissionId) async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;

    try {
      await repository.castVote(
        challengeId: challengeId,
        submissionId: submissionId,
        userId: userId,
      );
      await fetchSubmissions(challengeId);
    } catch (e) {
    }
  }

  String getChallengeStatusLabel(ChallengeModel challenge) {
    return repository.getChallengeStatus(challenge);
  }

  bool checkDeadlineNear(ChallengeModel challenge) {
    return repository.isEntryDeadlineNear(challenge);
  }

  void _showPinkToast(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFFFF69B4).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(24),
      borderRadius: 20,
    );
  }
}
