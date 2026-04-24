import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileRepository {
  final AuthProvider authProvider;
  final UserProvider userProvider;
  ProfileRepository({required this.authProvider, required this.userProvider});
  Stream<AuthState> get authStateChanges => authProvider.authStateChanges;
  User? get currentUser => authProvider.currentUser;

  Future<UserModel?> fetchUser(String userId) async {
    return userProvider.getUser(userId);
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    return userProvider.updateUser(userId, data);
  }

  Future<void> upsertUserData(String userId, Map<String, dynamic> data) async {
    return userProvider.upsertUser(userId, data);
  }

  Future<bool> checkIsFollowing(String followerId, String targetUserId) async {
    return userProvider.isFollowing(followerId, targetUserId);
  }

  Future<void> toggleFollow(String followerId, String targetUserId, bool isCurrentlyFollowing) async {
    if (isCurrentlyFollowing) {
      return userProvider.unfollowUser(followerId, targetUserId);
    } else {
      return userProvider.followUser(followerId, targetUserId);
    }
  }

  Future<AuthResponse> loginWithGoogle() async {
    return authProvider.signInWithGoogle();
  }

  Future<void> logout() async {
    return authProvider.signOut();
  }

  Future<String> uploadAvatar(String userId, File file) async {
    return userProvider.uploadAvatar(userId, file);
  }
}
