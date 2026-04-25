import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/community_repository.dart';

class CommunityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CommunityRepository repository;
  
  CommunityController({required this.repository});
  
  var selectedTabIndex = 0.obs;
  late TabController tabController;
  final selectedCategory = 'trending'.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  int _offset = 0;
  bool _hasMorePosts = true;
  final int _limit = 12;

  final posts = <PostModel>[].obs;
  final featuredPost = Rxn<PostModel>();

  final profileController = Get.find<ProfileController>();
  
  
  final bannerIndex = 0.obs;
  late PageController bannerPageController;
  Timer? _bannerTimer;
  
  final List<Map<String, String>> communityBanners = [
    {
      'image': 'assets/images/community/banner_1.png',
      'title': 'GLOBAL CONNECTION',
      'subtitle': 'NETWORKING THE FUTURE',
      'label': 'ArtVerse Connect'
    },
    {
      'image': 'assets/images/community/banner_2.png',
      'title': 'VIBRANT CREATIVITY',
      'subtitle': 'BEYOND THE CANVAS',
      'label': 'ArtVerse Pulse'
    },
    {
      'image': 'assets/images/community/banner_3.png',
      'title': 'MASTER COLLABORATION',
      'subtitle': 'SHARED INSPIRATION',
      'label': 'ArtVerse Studio'
    },
  ];

  void changeTab(int index) {
    selectedTabIndex.value = index;
    tabController.animateTo(index);
  }

  var searchText = ''.obs;
  final searchController = TextEditingController();

  void updateSearch(String value) {
    searchText.value = value;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    reload();
  }

  void openPostDetail(PostModel post) {
    if (post.id != null) {
      repository.recordView(post.id!);
      if (post.isVideo) {
        Get.toNamed<void>('/watch/${post.id}');
      } else {
        Get.toNamed<void>('/view/${post.id}');
      }
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể tải nội dung. Thiếu ID bài đăng.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }

  bool get isSearching => searchText.value.trim().isNotEmpty;

  final categories = [
    'all',
    'art_photos',
    'video_film',
    'trending',
    'illustrations',
    'animations',
    'sculpture',
    'following'
  ];

  List<PostModel> get filteredPosts {
    if (isSearching) return posts;

    return posts.where((p) {
      final url = p.url.toLowerCase();
      final isVideo = url.contains('.m3u8') || 
                      url.contains('/videos/') || 
                      url.contains('.mp4') || 
                      url.contains('.mov');

      if (selectedCategory.value == 'art_photos') return !isVideo;
      if (selectedCategory.value == 'video_film') return isVideo;
      if (selectedCategory.value == 'animations') return isVideo;
      if (selectedCategory.value == 'all') return true;
      return true;
    }).toList();
  }

  @override
  void onInit() async {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedTabIndex.value = tabController.index;
      }
    });
    bannerPageController = PageController();
    _startBannerTimer();
    
    scrollController.addListener(_scrollListener);
    super.onInit();
    await reload();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (bannerPageController.hasClients) {
        final next = (bannerIndex.value + 1) % communityBanners.length;
        bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void onBannerChanged(int index) {
    bannerIndex.value = index;
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && _hasMorePosts && !isSearching) {
        _loadMorePosts();
      }
    }
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    searchController.dispose();
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> reload() async {
    if (!await profileController.checkNetworkConnection()) {
      _showErrorSnackBar('No Internet', 'Please check your network connection');
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _offset = 0;
    _hasMorePosts = true;
    posts.clear();
    featuredPost.value = null;
    await _loadInitialPosts();
    isLoading.value = false;
  }

  Future<void> _loadInitialPosts() async {
    try {
      final results = await repository.fetchPosts(
        limit: _limit,
        offset: _offset,
        category: selectedCategory.value,
      );

      if (results.isEmpty) {
        _hasMorePosts = false;
        return;
      }

      if (results.length < _limit) {
        _hasMorePosts = false;
      }

      await _processPostsAndUpdate(results, isAppend: false);

      if (posts.isNotEmpty) {
        featuredPost.value = posts.first;
      }
    } catch (e) {
      posts.value = [];
    }
  }

  Future<void> _loadMorePosts() async {
    if (!await profileController.checkNetworkConnection()) {
      return;
    }

    isLoadingMore.value = true;
    try {
      _offset += _limit;
      final results = await repository.fetchPosts(
        limit: _limit,
        offset: _offset,
        category: selectedCategory.value,
      );

      if (results.isEmpty) {
        _hasMorePosts = false;
        isLoadingMore.value = false;
        return;
      }

      if (results.length < _limit) {
        _hasMorePosts = false;
      }

      await _processPostsAndUpdate(results, isAppend: true);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _processPostsAndUpdate(
    List<Map<String, dynamic>> results, {
    required bool isAppend,
  }) async {
    final postsWithUser = await Future.wait(
      results.map((data) async {
        final postModel = PostModel.fromJson(data);
        try {
          postModel.user = await profileController.getUser(
            postModel.userId,
            showLoading: false,
          );
        } catch (_) {}
        return postModel;
      }),
    );

    final processedPosts = postsWithUser.toList();

    if (isAppend) {
      posts.addAll(processedPosts);
    } else {
      posts.assignAll(processedPosts);
    }
  }

  Future<void> handleLike(PostModel post) async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;

    try {
      await repository.handleToggleLike(
        postId: post.id!,
        userId: userId,
        isLike: true,
      );
    } catch (e) {
    }
  }

  Future<void> searchPosts(String queryText) async {
    if (queryText.isEmpty) {
      await reload();
      return;
    }
    if (!await profileController.checkNetworkConnection()) return;

    try {
      isLoading.value = true;
      final results = await repository.fetchPosts(
        limit: _limit,
        searchQuery: queryText,
      );

      await _processPostsAndUpdate(results, isAppend: false);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
    );
  }
}
