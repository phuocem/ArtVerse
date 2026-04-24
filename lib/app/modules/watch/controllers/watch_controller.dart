import 'package:better_player_plus/better_player_plus.dart';
import 'package:artverse/app/data/models/comment_model.dart';
import 'package:artverse/app/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/models/user_model.dart';
import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/services/database_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/watch_repository.dart';

class WatchController extends GetxController {
  final WatchRepository repository;

  WatchController({required this.repository});

  final post = Rxn<PostModel>();
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final profileController = Get.find<ProfileController>();
  final comments = <CommentModel>[].obs;
  final relatedVideos = <PostModel>[].obs;

  final isLiked = false.obs;
  final likeCount = 0.obs;
  final isLikeLoading = false.obs;
  
  final isPanelVisible = true.obs;

  BetterPlayerController? playerController;

  void togglePanel() => isPanelVisible.value = !isPanelVisible.value;

  @override
  void onInit() async {
    super.onInit();
    final id = Get.parameters['id'];
    if (id != null) {
      await fetchVideo(id);
      await getComments(id);
      await fetchLikeStatus(id);
    }
  }

  @override
  void onClose() {
    playerController?.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> fetchVideo(String id) async {
    isLoading.value = true;
    final hasConnection = await profileController.checkNetworkConnection();
    if (!hasConnection) {
      _showPinkSnackbar('Network error', 'No Internet Connection');
      isLoading.value = false;
      return;
    }

    try {
      final postData = await repository.fetchVideoData(id);

      if (postData != null) {
        post.value = postData;
        await repository.updateViews(id, post.value?.views ?? 0);

        try {
          user.value = await profileController.getUser(post.value!.userId);
        } catch (e) {
          user.value = UserModel(
            id: 'unknown',
            name: 'Studio Artist',
            email: '',
            bio: '🌸 ArtVerse Creator 💗',
            createdAt: DateTime.now(),
            editedAt: DateTime.now(),
          );
        }

        final isVideo = post.value!.isVideo;
        final isHls = post.value!.url.toLowerCase().contains('.m3u8');

        if (isVideo) {
          _initializePlayer(isHls);
        }

        await fetchRelated();
      } else {
        _showPinkSnackbar('Not Found', 'This video does not exist');
        isLoading.value = false;
        Future.delayed(const Duration(seconds: 1), () {
          if (Get.currentRoute.contains(id)) Get.back<void>();
        });
        return;
      }
    } catch (e) {
      _showPinkSnackbar('Error', 'Could not load video');
    } finally {
      isLoading.value = false;
    }
  }

  void _initializePlayer(bool isHls) {
    playerController?.dispose();
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      post.value!.url,
      videoFormat: isHls ? BetterPlayerVideoFormat.hls : BetterPlayerVideoFormat.other,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: true),
    );
    playerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
        fit: BoxFit.contain,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: false,
          enableQualities: false,
          enableAudioTracks: false,
          enableFullscreen: true,
          controlBarColor: Colors.black54,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  Future<void> fetchRelated() async {
    if (post.value?.category == null) return;
    try {
      final list = await repository.getRecommendedVideos(post.value!.category!);
      relatedVideos.assignAll(list.where((v) => v.id != post.value?.id));
    } catch (e) {
    }
  }

  Future<void> fetchLikeStatus(String postId) async {
    try {
      final userId = profileController.currentUser.value?.id;
      if (userId == null) return;
      isLiked.value = await repository.getUserLikeStatus(postId, userId);
      likeCount.value = post.value?.likesCount ?? 0;
    } catch (e) {
    }
  }

  Future<void> toggleLike() async {
    final postId = post.value?.id;
    final userId = profileController.currentUser.value?.id;

    if (postId == null || userId == null) return;
    if (isLikeLoading.value) return;

    isLikeLoading.value = true;
    final wasLiked = isLiked.value;

    try {
      await repository.handleToggleLike(
        postId: postId,
        userId: userId,
        isCurrentlyLiked: wasLiked,
      );

      isLiked.value = !wasLiked;
      likeCount.value = (likeCount.value + (wasLiked ? -1 : 1)).clamp(0, 999999);
    } catch (e) {
      _showPinkSnackbar('Error', 'Could not update like');
    } finally {
      isLikeLoading.value = false;
    }
  }

  final commentController = TextEditingController();
  final isPostingComment = false.obs;

  Future<void> postComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;

    isPostingComment.value = true;
    try {
      await repository.submitNewComment(
        postId: post.value!.id!,
        commentData: {
          'user_id': userId,
          'content': content,
        },
      );
      commentController.clear();
      await getComments(post.value!.id!);
    } catch (e) {
      _showPinkSnackbar('Error', 'Could not post comment');
    } finally {
      isPostingComment.value = false;
    }
  }

  Future<void> getComments(String id) async {
    try {
      final list = await repository.fetchVideoComments(id);
      final fetchedComments = list.map((data) => CommentModel.fromJson(data)).toList();

      comments.value = await Future.wait(
        fetchedComments.map((comment) async {
          try {
            comment.user = await profileController.getUser(comment.userId);
          } catch (_) {}
          return comment;
        }),
      );
    } catch (e) {
      comments.clear();
    }
  }

  Future<void> remixProject(String projectUrl) async {
    try {
      Get.dialog<void>(
        const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4))),
        barrierDismissible: false,
      );

      final response = await http.get(Uri.parse(projectUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final project = DrawProjectModel.fromJson(jsonMap);

        final newId = "remix_${DateTime.now().millisecondsSinceEpoch}";
        final newProject = DrawProjectModel(
          id: newId,
          name: "${project.name} (Remix)",
          updatedAt: DateTime.now(),
          frames: project.frames,
        );

        final box = Get.find<DatabaseService>().drawProjectBox;
        await box.put(newId, newProject);

        Get.back<void>(); 
        Get.back<void>(); 

        Get.toNamed<void>('/draw', arguments: newId);
        _showPinkSnackbar("🌸 Remix Success 💗", "Project cloned and ready to draw!");
      } else {
        Get.back();
        _showPinkSnackbar("Failed", "Could not download the project template.");
      }
    } catch (e) {
      Get.back();
      _showPinkSnackbar("Error", "Error while remixing: $e");
    }
  }

  void _showPinkSnackbar(String title, String message) {
    Get.snackbar(
      "🌸 $title 💗",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF69B4).withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(24),
      borderRadius: 20,
    );
  }
}
