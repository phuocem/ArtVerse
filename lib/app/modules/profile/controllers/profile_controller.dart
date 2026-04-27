import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/app_globals.dart';
import '../../home/controllers/home_controller.dart';
import '../../community/controllers/notification_controller.dart';
import '../../../data/models/draw/drawn_line_model.dart';
import '../../../data/models/draw/frame_model.dart';
import '../../../data/models/draw/layer_model.dart';
import '../../../data/models/draw/draw_project_model.dart';
import '../repositories/profile_repository.dart';
import '../../layout/controllers/layout_controller.dart';
class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ProfileRepository repository;
  final homeController = Get.find<HomeController>();
  ProfileController({required this.repository});
  final isLoading = false.obs;
  final isCurrentUser = false.obs;
  RxBool hasNetwork = true.obs;
  var currentUser = Rxn<UserModel>();
  var viewedUser = Rxn<UserModel>();
  final isLogined = false.obs;
  final followingMap = <String, bool>{}.obs;
  final Map<String, UserModel> _userCache = {};
  var post = <PostModel>[].obs;
  final isLoadingMore = false.obs;
  final selectedTab = 'All'.obs;
  final List<String> tabArt = ['All', '2D Art'];
  final ScrollController scrollController = ScrollController();
  final RxInt crossAxisCount = 3.obs;
  final isMaleMode = true.obs;
  int _currentPostPage = 0;
  bool _hasMorePosts = true;
  final int _postLimit = 15;
  final equippedFrameUrl = RxnString();
  final ownedGear = <dynamic>[].obs;
  List<PostModel> get filteredPosts => post;
  late final userBox = Get.find<DatabaseService>().userBox;
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    isLoading.value = true;
    isCurrentUser.value = false;
    repository.authStateChanges.listen((AuthState state) {
      final user = state.session?.user;
      if (user != null) {
        isLogined.value = true;
        _handleUserLoggedIn(user.id);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.currentRoute != '/layout') {
            Get.offAllNamed<void>('/layout');
          }
        });
      } else {
        isLogined.value = false;
        currentUser.value = null;
      }
    });
  }
  Future<void> _handleUserLoggedIn(String uid) async {
    if (currentUser.value == null) {
      try {
        final user = await getUser(uid, showLoading: false);
        currentUser.value = user;
        viewedUser.value = user;
        isCurrentUser.value = true;
        await userBox.put('current_user', user);
        _loadPersonaGear();
        _checkFirstTimeSetup(user);
      } catch (e) {
      }
    } else {
       _loadPersonaGear();
    }
  }
  void _checkFirstTimeSetup(UserModel user) {
    if (user.handle == null || user.handle!.isEmpty || user.gender == null || user.gender!.isEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        showFirstTimeSetupDialog(user);
      });
    }
  }
  void showFirstTimeSetupDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final handleController = TextEditingController(text: user.name.toLowerCase().replaceAll(' ', ''));
    final isMale = true.obs;
    final isUpdating = false.obs;
    Get.generalDialog(
      barrierDismissible: false,
      barrierLabel: 'First Time Setup',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("WELCOME TO ARTVERSE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const SizedBox(height: 12),
                    const Text("Let's personalize your studio persona",
                        style: TextStyle(color: Colors.white38, fontSize: 14)),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderCard(
                            true, "MASCULINE", Icons.male_rounded, isMale),
                        const SizedBox(width: 24),
                        _buildGenderCard(
                            false, "FEMININE", Icons.female_rounded, isMale),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildSetupField(
                        "Your Artist Name", nameController, Icons.brush_rounded),
                    const SizedBox(height: 20),
                    _buildSetupField("Studio Handle (@)", handleController,
                        Icons.alternate_email_rounded),
                    const SizedBox(height: 48),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: isUpdating.value
                                ? null
                                : () async {
                                    try {
                                      final rawName = nameController.text.trim();
                                      final rawHandle = handleController.text.trim();
                                      if (rawName.isEmpty) {
                                        _showSnackbar("Warning", "Vui lòng nhập tên của bạn");
                                        return;
                                      }
                                      if (rawHandle.isEmpty) {
                                        _showSnackbar("Warning", "Vui lòng nhập Studio Handle");
                                        return;
                                      }
                                      final cleanHandle = rawHandle
                                          .toLowerCase()
                                          .replaceAll(RegExp(r'\s+'), '')
                                          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
                                      isUpdating.value = true;
                                      if (user.id == null) throw "Không tìm thấy User ID";
                                      if (user.email.isEmpty) throw "Không tìm thấy Email người dùng";
                                      isMaleMode.value = isMale.value;
                                      final update = {
                                        'name': rawName,
                                        'handle': cleanHandle.isEmpty ? "user_${user.id!.substring(0, 5)}" : cleanHandle,
                                        'gender': isMale.value ? 'male' : 'female',
                                        'email': user.email,
                                      };
                                      await repository.updateUserData(user.id!, update).timeout(const Duration(seconds: 15));
                                      user.name = rawName;
                                      user.handle = update['handle']!;
                                      user.gender = update['gender']!;
                                      await userBox.put('current_user', user);
                                      currentUser.refresh();
                                      Get.back(); 
                                      _showSnackbar("Studio Ready", "Chào mừng bạn gia nhập ArtVerse, ${user.name}!");
                                    } catch (e) {
                                      debugPrint("PROFILE_SETUP_ERROR: $e");
                                      _showSnackbar("Error", "Thiết lập thất bại: $e");
                                    } finally {
                                      isUpdating.value = false;
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMale.value
                                  ? const Color(0xFF00CFA8)
                                  : const Color(0xFFFF4D8A),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: isUpdating.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text("CONFIRM STUDIO PROFILE",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)), child: child),
        );
      }
    );
  }
  Widget _buildGenderCard(bool male, String label, IconData icon, RxBool group) {
    return Obx(() {
      final active = group.value == male;
      final color = male ? const Color(0xFF00CFA8) : const Color(0xFFFF4D8A);
      return GestureDetector(
        onTap: () => group.value = male,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: active ? color : Colors.white.withValues(alpha: 0.05), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? color : Colors.white24, size: 48),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(color: active ? color : Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildSetupField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white24, size: 18),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _loadPersonaGear() {
    final db = Get.find<DatabaseService>();
    final gear = db.settingsBox.get('persona_gear', defaultValue: <dynamic>[]);
    ownedGear.assignAll(gear);
    final frames = gear.where((g) => g['type'] == 'avatar_frame').toList();
    if (frames.isNotEmpty) {
      equippedFrameUrl.value = frames.last['thumbnail_url'];
    }
  }
  void setEquippedFrame(String? url) {
    equippedFrameUrl.value = url;
  }
  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && _hasMorePosts) {
        final userId = viewedUser.value?.id ?? currentUser.value?.id;
        if (userId != null) {
          loadMorePostsByCurrentUser(userId);
        }
      }
    }
  }
  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
  @override
  void onReady() async {
    super.onReady();
    await reload();
  }
  Future<bool> checkNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      hasNetwork.value = false;
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasNetwork.value = true;
        return true;
      } else {
        hasNetwork.value = false;
        return false;
      }
    } catch (e) {
      hasNetwork.value = false;
      return false;
    }
  }
  Future<void> reload() async {
    isLoading.value = true;
    try {
      await loadCurrentUserFromHive();
      if (currentUser.value == null) {
        final supaUser = repository.currentUser;
        if (supaUser != null) {
          await _handleUserLoggedIn(supaUser.id);
        }
      }
      if (currentUser.value != null) {
        isLogined.value = true;
        isCurrentUser.value = true;
        await getAllPostsByCurrentUser(currentUser.value!.id ?? '');
      } else {
        isLogined.value = false;
        isCurrentUser.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> initProfile(String? userId) async {
    if (userId == null) {
      await loadCurrentUserFromHive();
      return;
    }
    isLoading.value = true;
    try {
      final user = await repository.fetchUser(userId);
      if (user != null) {
        viewedUser.value = user;
        isCurrentUser.value = currentUser.value?.id == userId;
        if (!isCurrentUser.value && isLogined.value) {
          await checkIsFollowing(userId);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadCurrentUserFromHive() async {
    final box = userBox;
    final user = box.get('current_user');
    if (user != null) {
      currentUser.value = user;
      viewedUser.value = user;
      isLogined.value = true;
      isCurrentUser.value = true;
    } else {
      isLogined.value = false;
    }
  }
  Future<void> checkIsFollowing(String targetUserId) async {
    final currentId = currentUser.value?.id;
    if (currentId == null) return;
    try {
      followingMap[targetUserId] = await repository.checkIsFollowing(currentId, targetUserId);
    } catch (e) {
      followingMap[targetUserId] = false;
    }
  }
  Future<void> toggleFollowUser(UserModel? userToFollow) async {
    if (!isLogined.value) {
      Get.snackbar("error".tr, "login_required_follow".tr);
      return;
    }
    final targetUserId = userToFollow?.id;
    final currentId = currentUser.value?.id;
    if (targetUserId == null || currentId == null) return;
    if (targetUserId == currentId) return;
    if (!await checkNetworkConnection()) {
      Get.snackbar("error".tr, "check_network".tr);
      return;
    }
    final wasFollowing = followingMap[targetUserId] ?? false;
    followingMap[targetUserId] = !wasFollowing;
    if (viewedUser.value?.id == targetUserId) {
      viewedUser.value!.followersCount += wasFollowing ? -1 : 1;
      viewedUser.refresh();
    }
    if (currentUser.value != null) {
      currentUser.value!.followingCount += wasFollowing ? -1 : 1;
      await userBox.put('current_user', currentUser.value!);
    }
    try {
      await repository.toggleFollow(currentId, targetUserId, wasFollowing);
      if (!wasFollowing) {
        await NotificationController.triggerNotification(
          type: 'follow',
          targetId: targetUserId,
          message: "started following your studio!",
        );
      }
    } catch (e) {
      followingMap[targetUserId] = wasFollowing;
      if (viewedUser.value?.id == targetUserId) {
        viewedUser.value!.followersCount += wasFollowing ? 1 : -1;
        viewedUser.refresh();
      }
      if (currentUser.value != null) {
        currentUser.value!.followingCount += wasFollowing ? 1 : -1;
      }
      Get.snackbar("error".tr, "follow_error".tr);
    }
  }
  Future<void> toggleFollow() async {
    await toggleFollowUser(viewedUser.value);
  }
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId);
      final futures = (response as List).map((doc) async {
        final followerId = doc['follower_id'] as String?;
        if (followerId != null) {
          return await getUser(followerId);
        }
        return null;
      });
      final results = await Future.wait(futures);
      return results.whereType<UserModel>().toList();
    } catch (e) {
      return [];
    }
  }
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);
      final futures = (response as List).map((doc) async {
        final followingId = doc['following_id'] as String?;
        if (followingId != null) {
          return await getUser(followingId);
        }
        return null;
      });
      final results = await Future.wait(futures);
      return results.whereType<UserModel>().toList();
    } catch (e) {
      return [];
    }
  }
  Future<UserModel> getUser(String userId, {bool showLoading = true}) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }
    if (!await checkNetworkConnection()) {
      throw Exception("No Internet connection");
    }
    if (showLoading) isLoading.value = true;
    try {
      final user = await repository.fetchUser(userId);
      if (user != null) {
        _userCache[userId] = user;
        return user;
      } else {
        throw Exception("No user found with id: $userId");
      }
    } catch (e) {
      rethrow;
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }
  Future<void> getAllPostsByCurrentUser(String userId) async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Unable to load posts");
      return;
    }
    _currentPostPage = 0;
    _hasMorePosts = true;
    post.clear();
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(_postLimit);
      final docs = List<Map<String, dynamic>>.from(response);
      if (docs.isEmpty) {
        _hasMorePosts = false;
        return;
      }
      _currentPostPage = docs.length;
      if (docs.length < _postLimit) {
        _hasMorePosts = false;
      }
      post.value = docs.map((data) => PostModel.fromJson(data)).toList();
    } catch (e) {
      post.value = [];
    }
  }
  Future<void> loadMorePostsByCurrentUser(String userId) async {
    if (!await checkNetworkConnection() || !_hasMorePosts) return;
    isLoadingMore.value = true;
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(_currentPostPage, _currentPostPage + _postLimit - 1);
      final docs = List<Map<String, dynamic>>.from(response);
      if (docs.isEmpty) {
        _hasMorePosts = false;
        isLoadingMore.value = false;
        return;
      }
      _currentPostPage += docs.length;
      if (docs.length < _postLimit) {
        _hasMorePosts = false;
      }
      final newPosts = docs.map((data) => PostModel.fromJson(data)).toList();
      post.addAll(newPosts);
    } finally {
      isLoadingMore.value = false;
    }
  }
  Future<void> fetchPostsByUser(String userId) async {
    await getAllPostsByCurrentUser(userId);
  }
  Future<void> signInWithGoogle() async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Cannot login while offline");
      return;
    }
    try {
      final authResponse = await repository.loginWithGoogle();
      final user = authResponse.user;
      if (user == null || user.email == null) {
        throw Exception("User not found or email missing");
      }
      var userDataModel = await repository.fetchUser(user.id);
      if (userDataModel == null) {
        final newUserData = {
          'name': user.userMetadata?['full_name'] ?? '',
          'email': user.email!,
          'bio': 'Welcome to my ArtVerse Studio',
          'avatar_url': user.userMetadata?['avatar_url'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'edited_at': DateTime.now().toIso8601String(),
          'balance': 0.0,
          'is_studio': false,
        };
        await repository.upsertUserData(user.id, newUserData);
        userDataModel = UserModel.fromJson({...newUserData, 'id': user.id});
      } else {
        await repository.updateUserData(user.id, {
          'avatar_url': user.userMetadata?['avatar_url'] ?? userDataModel.avatarUrl,
        });
        userDataModel = await repository.fetchUser(user.id);
      }
      if (userDataModel != null) {
        await userBox.put('current_user', userDataModel);
        isLogined.value = true;
        await initProfile(null);
        _showSnackbar("Đăng nhập thành công", "Chào mừng trở lại, ${userDataModel.name}!");
        await reload();
        Get.offAllNamed<void>('/layout');
      }
    } catch (e) {
      _showSnackbar("Lỗi đăng nhập", e.toString());
    }
  }
  void _showSnackbar(String title, String message) {
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
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  Future<void> upgradeToStudio() async {
    final user = currentUser.value;
    if (user == null) return;
    if (user.balance < 50.0) {
      Get.snackbar("Insufficient Balance", "Please top up at least 50.0 ArtCoins to unlock Studio Advanced.");
      return;
    }
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final newBalance = user.balance - 50.0;
      await supabase.from('users').update({
        'is_studio': true,
        'balance': newBalance,
      }).eq('id', user.id!);
      user.isStudio = true;
      user.balance = newBalance;
      await userBox.put('current_user', user);
      currentUser.refresh();
      Get.snackbar("Congratulations!", "You are now an ArtVerse Studio Member!",
          backgroundColor: const Color(0xFFFF69B4), colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to upgrade. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> topUp(double amount) async {
    final user = currentUser.value;
    if (user == null) return;
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final newBalance = user.balance + amount;
      await supabase.from('users').update({
        'balance': newBalance,
      }).eq('id', user.id!);
      user.balance = newBalance;
      await userBox.put('current_user', user);
      currentUser.refresh();
      Get.snackbar("Top-up Success", "Added $amount ArtCoins to your account.");
    } catch (e) {
      Get.snackbar("Error", "Failed to top up.");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> signOutGoogleAndClearHive() async {
    try {
      await repository.logout();
      final box = userBox;
      await box.delete('current_user');
      currentUser.value = null;
      viewedUser.value = null;
      isLogined.value = false;
    } catch (e) {
      _showSnackbar("Logout error", e.toString());
    }
  }
  void showEditProfileDialog({
    required String id,
    required String name,
    required String bio,
    required String? avatarUrl,
    required void Function() onUpdated,
  }) {
    final lc = Get.find<LayoutController>();
    final nameController = TextEditingController(text: name);
    final bioController = TextEditingController(text: bio);
    final handleController = TextEditingController(text: currentUser.value?.handle ?? '');
    final handleText = (currentUser.value?.handle ?? '').obs;
    handleController.addListener(() => handleText.value = handleController.text);
    final locationController = TextEditingController(text: currentUser.value?.location ?? '');
    final websiteController = TextEditingController(text: currentUser.value?.website ?? '');
    final instagramController = TextEditingController(text: currentUser.value?.instagramUrl ?? '');
    final twitterController = TextEditingController(text: currentUser.value?.twitterUrl ?? '');
    final Rx<File?> selectedAvatar = Rx<File?>(null);
    final isUpdating = false.obs;
    final activeTab = 0.obs;
    final gender = (currentUser.value?.gender ?? "").obs;
    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: 'Edit Profile',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 640,
              height: 520,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    lc.cardColor,
                    lc.backgroundColor,
                  ],
                ),
                border: Border.all(color: lc.primaryColor.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: lc.primaryColor.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 2),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 80),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Row(
                  children: [
                    _buildFluidSidebar(activeTab, lc),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 8),
                                child: Column(
                                  children: [
                                    _buildCelestialAvatar(selectedAvatar, avatarUrl, lc),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: nameController,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: lc.textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Tên của bạn",
                                        hintStyle: TextStyle(color: lc.subtextColor),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    Obx(() => Text(
                                      "@${handleText.value.isEmpty ? "handle" : handleText.value}",
                                      style: TextStyle(
                                        color: lc.primaryColor,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                        fontSize: 11,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Obx(() => AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                                    child: KeyedSubtree(
                                      key: ValueKey(activeTab.value),
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: _buildCurrentFluidTab(activeTab.value, handleController, bioController, locationController, websiteController, instagramController, twitterController, gender, lc),
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                          Positioned(
                            bottom: 20, left: 0, right: 0,
                            child: Center(child: _buildFloatingActionHub(id, isUpdating, nameController, bioController, locationController, websiteController, instagramController, twitterController, handleController, selectedAvatar, avatarUrl, gender, onUpdated, lc)),
                          ),
                          Positioned(
                            top: 16, right: 20,
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: lc.glassColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: lc.glassBorderColor),
                                ),
                                child: Icon(Icons.close_rounded, color: lc.textColor.withValues(alpha: 0.6), size: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
    );
  }
  Widget _buildFluidSidebar(RxInt activeTab, LayoutController lc) {
    final icons = [Icons.face_retouching_natural_rounded, Icons.hub_rounded];
    return Container(
      width: 54,
      decoration: BoxDecoration(
        color: lc.glassColor,
        border: Border(right: BorderSide(color: lc.glassBorderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: List.generate(icons.length, (i) => Obx(() {
          final active = activeTab.value == i;
          return GestureDetector(
            onTap: () => activeTab.value = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: active ? lc.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: active ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 12)] : []
              ),
              child: Icon(icons[i], color: active ? lc.onPrimaryColor : lc.textColor.withValues(alpha: 0.4), size: 16),
            ),
          );
        })),
      ),
    );
  }
  Widget _buildCelestialAvatar(Rx<File?> selected, String? current, LayoutController lc) {
    return Obx(() => SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: lc.primaryColor.withValues(alpha: 0.4), width: 2),
              boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.2), blurRadius: 16)],
            ),
            child: ClipOval(
              child: selected.value != null
                ? Image.file(selected.value!, fit: BoxFit.cover)
                : (current != null
                    ? CachedNetworkImage(imageUrl: current, fit: BoxFit.cover)
                    : Container(
                        color: lc.glassColor,
                        child: Icon(Icons.person_rounded, color: lc.primaryColor.withValues(alpha: 0.4), size: 32),
                      )),
            ),
          ),
          Positioned(
            bottom: 2, right: 2,
            child: GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) selected.value = File(result!.files.single.path!);
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: lc.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: lc.backgroundColor, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, size: 10, color: lc.onPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    ));
  }
  Widget _buildCurrentFluidTab(int tab, TextEditingController h, TextEditingController b, TextEditingController l, TextEditingController w, TextEditingController i, TextEditingController t, RxString gender, LayoutController lc) {
    switch(tab) {
      case 0: return Column(children: [
        _buildWhisperField(Icons.alternate_email_rounded, "Handle (@)", h, lc),
        _buildWhisperField(Icons.notes_rounded, "Bio", b, lc, maxLines: 3),
        _buildGenderSelector(gender, lc),
      ]);
      case 1: return Column(children: [
        _buildWhisperField(Icons.place_rounded, "Địa điểm", l, lc),
        _buildWhisperField(Icons.public_rounded, "Website", w, lc),
        _buildWhisperField(Icons.camera_rounded, "Instagram", i, lc),
        _buildWhisperField(Icons.chat_bubble_rounded, "X / Twitter", t, lc),
      ]);
      default: return const SizedBox();
    }
  }

  Widget _buildWhisperField(IconData icon, String hint, TextEditingController ctrl, LayoutController lc, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hint.toUpperCase(), style: TextStyle(color: lc.subtextColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: TextStyle(color: lc.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: lc.primaryColor.withValues(alpha: 0.5), size: 16),
              filled: true,
              fillColor: lc.glassColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: lc.glassBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: lc.primaryColor, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGenderSelector(RxString gender, LayoutController lc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GIỚI TÍNH", style: TextStyle(color: lc.subtextColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Obx(() => Row(
            children: ['Nam', 'Nữ', 'Khác'].map((g) {
              final active = gender.value == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => gender.value = g,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? lc.primaryColor.withValues(alpha: 0.1) : lc.glassColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: active ? lc.primaryColor : lc.glassBorderColor),
                    ),
                    child: Center(child: Text(g, style: TextStyle(color: active ? lc.primaryColor : lc.textColor, fontSize: 12, fontWeight: FontWeight.w700))),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildFloatingActionHub(String id, RxBool isUpdating, TextEditingController name, TextEditingController bio, TextEditingController loc, TextEditingController web, TextEditingController insta, TextEditingController twit, TextEditingController handle, Rx<File?> selectedAvatar, String? currentAvatar, RxString gender, void Function() onUpdated, LayoutController lc) {
    return Obx(() => GestureDetector(
      onTap: isUpdating.value ? null : () async {
        isUpdating.value = true;
        try {
          String? newAvatarUrl = currentAvatar;
          if (selectedAvatar.value != null) newAvatarUrl = await repository.uploadAvatar(id, selectedAvatar.value!);
          final updatedData = {
            'name': name.text.trim(), 'bio': bio.text.trim(), 'location': loc.text.trim(),
            'website': web.text.trim(), 'instagram_url': insta.text.trim(), 'twitter_url': twit.text.trim(),
            'handle': handle.text.trim(), 'avatar_url': newAvatarUrl,
            'gender': gender.value,
          };
          await repository.updateUserData(id, updatedData);
          final newUser = UserModel.fromJson({...updatedData, 'id': id, 'email': currentUser.value?.email ?? ''});
          await userBox.put('current_user', newUser);
          currentUser.value = newUser; viewedUser.value = newUser;
          currentUser.refresh(); viewedUser.refresh();
          onUpdated(); Get.back();
          _showSnackbar("Đã lưu", "Hồ sơ của bạn đã được cập nhật.");
        } catch (e) {
          _showSnackbar("Lỗi", e.toString());
        } finally {
          isUpdating.value = false;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUpdating.value ? null : LinearGradient(colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.7)]),
          color: isUpdating.value ? lc.glassColor : null,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isUpdating.value ? [] : [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: isUpdating.value
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: lc.primaryColor, strokeWidth: 2))
          : Text("LƯU HỒ SƠ", style: TextStyle(color: lc.onPrimaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
      ),
    ));
  }
  Future<void> updateStatus({required int id, required int status}) async {
    Get.snackbar("Unavailable", "Online features have been removed.");
  }
  Future<void> deletePost({required String id}) async {
    post.removeWhere((p) => p.id == id);
    Get.snackbar("Deleted", "Post removed locally.");
  }
  Future<void> confirmDeletePost(String id) async {
    Get.defaultDialog(
      title: 'Confirm',
      middleText: 'Are you sure you want to delete this post?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      onConfirm: () async {
        Get.back();
        await deletePost(id: id);
      },
    );
  }
  void showStatusOptionsDialog(post) {
    Get.defaultDialog(
      title: 'Choose action',
      content: Column(
        children: [
          ListTile(
            leading: Icon(Icons.delete, color: Get.theme.colorScheme.error),
            title: const Text('Delete posts'),
            onTap: () async {
              Get.back();
              await confirmDeletePost(post.id);
            },
          ),
        ],
      ),
    );
  }
  void showSettingsOptions() {
    Get.defaultDialog(
      title: 'Settings',
      content: Column(
        children: [
          if (isLogined.value)
            ListTile(
              leading: Icon(Icons.logout, color: Get.theme.colorScheme.error),
              title: const Text('Sign out'),
              onTap: () async {
                Get.back();
                Get.defaultDialog(
                  title: 'Confirm',
                  middleText: 'Are you sure you want to sign out?',
                  textConfirm: 'Sign out',
                  textCancel: 'Cancel',
                  confirmTextColor: Get.theme.colorScheme.onError,
                  onConfirm: () async {
                    await signOutGoogleAndClearHive();
                    Get.back();
                    Get.snackbar(
                      "Sign out",
                      "You have successfully logged out.",
                    );
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup data'),
            onTap: () async {
              Get.back();
              await exportAll();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore data'),
            onTap: () async {
              Get.back();
              await importAll();
            },
          ),
        ],
      ),
    );
  }
  Future<void> exportAllHiveData(String filePath) async {
    final Map<String, dynamic> exportData = {};
    await checkOpenBox();
    final drawProjectBox = Get.find<DatabaseService>().drawProjectBox;
    final frameBox = Hive.box<FrameModel>('frameModel');
    final layerBox = Hive.box<LayerModel>('layerModel');
    final lineBox = Hive.box<DrawnLine>('drawnLine');
    exportData['drawProjectModel'] = drawProjectBox.toMap().map(
      (key, value) => MapEntry(key.toString(), value),
    );
    exportData['frameModel'] = frameBox.toMap().map(
      (key, value) => MapEntry(key.toString(), value),
    );
    exportData['layerModel'] = layerBox.toMap().map(
      (key, value) => MapEntry(key.toString(), value),
    );
    exportData['drawnLine'] = lineBox.toMap().map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final file = File(filePath);
    await file.writeAsString(jsonEncode(exportData));
  }
  Future<void> exportAll() async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) return;
    final fileNameController = TextEditingController(text: 'calliope_backup');
    await Get.defaultDialog(
      title: 'Name the backup file',
      barrierDismissible: false,
      content: Column(
        children: [
          const Text('Enter backup file name:'),
          const SizedBox(height: 8),
          TextField(
            controller: fileNameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          final rawName = fileNameController.text.trim();
          if (rawName.isEmpty) {
            Get.snackbar('Error', 'File name cannot be empty');
            return;
          }
          final fileName =
              rawName.endsWith('.json') ? rawName : '$rawName.json';
          Get.back();
          final dir = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOAD,
          );
          final filePath = '$dir/$fileName';
          await exportAllHiveData(filePath);
          Get.defaultDialog(
            title: 'Backup successful',
            middleText: 'Your projects has been exported to:\n$filePath',
            confirm: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          );
        },
        child: const Text('Save'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
  Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;
    await openAppSettings();
    return false;
  }
  Future<void> checkOpenBox() async {
    if (!Hive.isBoxOpen('draw_project')) {
      await Hive.openBox<DrawProjectModel>('draw_project');
    }
    if (!Hive.isBoxOpen('frameModel')) {
      await Hive.openBox<FrameModel>('frameModel');
    }
    if (!Hive.isBoxOpen('layerModel')) {
      await Hive.openBox<LayerModel>('layerModel');
    }
    if (!Hive.isBoxOpen('drawnLine')) {
      await Hive.openBox<DrawnLine>('drawnLine');
    }
  }
  Future<void> importAllHiveData(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("File does not exist: $filePath");
    }
    late Map<String, dynamic> jsonData;
    try {
      final contents = await file.readAsString();
      jsonData = jsonDecode(contents);
    } catch (e) {
      throw Exception("File is invalid or not in JSON format.\nDetail: $e");
    }
    final requiredKeys = [
      'drawProjectModel',
      'frameModel',
      'layerModel',
      'drawnLine',
    ];
    for (final key in requiredKeys) {
      if (!jsonData.containsKey(key)) {
        throw Exception("File missing data: '$key'");
      }
    }
    await checkOpenBox();
    final drawProjectBox = Get.find<DatabaseService>().drawProjectBox;
    final frameBox = Hive.box<FrameModel>('frameModel');
    final layerBox = Hive.box<LayerModel>('layerModel');
    final lineBox = Hive.box<DrawnLine>('drawnLine');
    await drawProjectBox.clear();
    await frameBox.clear();
    await layerBox.clear();
    await lineBox.clear();
    try {
      for (final entry
          in (jsonData['drawProjectModel'] as Map<String, dynamic>).entries) {
        final obj = DrawProjectModel.fromJson(entry.value);
        await drawProjectBox.put(entry.key, obj);
      }
      for (final entry
          in (jsonData['frameModel'] as Map<String, dynamic>).entries) {
        final obj = FrameModel.fromJson(entry.value);
        await frameBox.put(entry.key, obj);
      }
      for (final entry
          in (jsonData['layerModel'] as Map<String, dynamic>).entries) {
        final obj = LayerModel.fromJson(entry.value);
        await layerBox.put(entry.key, obj);
      }
      for (final entry
          in (jsonData['drawnLine'] as Map<String, dynamic>).entries) {
        final obj = DrawnLine.fromJson(entry.value);
        await lineBox.put(entry.key, obj);
      }
    } catch (e) {
      throw Exception("Error parsing or writing Hive data.\nDetails: $e");
    }
  }
  Future<void> importAll() async {
    try {
      bool isCancel = true;
      await Get.defaultDialog(
        barrierDismissible: false,
        title: 'Warning',
        middleText:
            'This will overwrite all your current projects. Are you sure?',
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
            isCancel = false;
          },
          child: const Text('Yes'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
            isCancel = true;
          },
          child: const Text('No'),
        ),
      );
      if (isCancel) return;
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) return;
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select the backup project file (.json)',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null ||
          result.files.isEmpty ||
          result.files.single.path == null) {
        return;
      }
      final path = result.files.single.path!;
      await importAllHiveData(path);
      homeController.loadProjects();
      Get.defaultDialog(
        title: 'Restore successfully',
        middleText: 'Data was successfully recovered.',
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
