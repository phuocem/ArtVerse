import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../../data/models/user_model.dart';

class UserProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> getUser(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _supabase.from('users').update({
      ...data,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> upsertUser(String userId, Map<String, dynamic> data) async {
    await _supabase.from('users').upsert({
      'id': userId,
      ...data,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<bool> isFollowing(String followerId, String targetUserId) async {
    final response = await _supabase
        .from('follows')
        .select('id')
        .eq('follower_id', followerId)
        .eq('following_id', targetUserId)
        .maybeSingle();
    return response != null;
  }

  Future<void> followUser(String followerId, String targetUserId) async {
    await _supabase.from('follows').insert({
      'follower_id': followerId,
      'following_id': targetUserId,
    });
    
    await _supabase.rpc('increment_field', params: {
      'row_id': targetUserId,
      'table_name': 'users',
      'field_name': 'followers_count',
      'amount': 1,
    }).onError((e, _) async {
      
      final target = await getUser(targetUserId);
      if (target != null) {
        await _supabase.from('users').update({
          'followers_count': target.followersCount + 1,
        }).eq('id', targetUserId);
      }
    });
    await _supabase.rpc('increment_field', params: {
      'row_id': followerId,
      'table_name': 'users',
      'field_name': 'following_count',
      'amount': 1,
    }).onError((e, _) async {
      final current = await getUser(followerId);
      if (current != null) {
        await _supabase.from('users').update({
          'following_count': current.followingCount + 1,
        }).eq('id', followerId);
      }
    });
  }

  Future<void> unfollowUser(String followerId, String targetUserId) async {
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', targetUserId);
    
    await _supabase.rpc('increment_field', params: {
      'row_id': targetUserId,
      'table_name': 'users',
      'field_name': 'followers_count',
      'amount': -1,
    }).onError((e, _) async {
      final target = await getUser(targetUserId);
      if (target != null) {
        await _supabase.from('users').update({
          'followers_count': (target.followersCount - 1).clamp(0, 999999),
        }).eq('id', targetUserId);
      }
    });
    await _supabase.rpc('increment_field', params: {
      'row_id': followerId,
      'table_name': 'users',
      'field_name': 'following_count',
      'amount': -1,
    }).onError((e, _) async {
      final current = await getUser(followerId);
      if (current != null) {
        await _supabase.from('users').update({
          'following_count': (current.followingCount - 1).clamp(0, 999999),
        }).eq('id', followerId);
      }
    });
  }

  Future<String> uploadAvatar(String userId, File file) async {
    final fileName = "avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final path = '$userId/$fileName';
    await _supabase.storage.from('avatars').upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }
}
