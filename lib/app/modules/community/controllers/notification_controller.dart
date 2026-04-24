import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../profile/controllers/profile_controller.dart';

class NotificationController extends GetxController {
  final profileController = Get.find<ProfileController>();
  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final currentUser = profileController.currentUser.value;
    if (currentUser == null || currentUser.id == null) return;

    Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('target_id', currentUser.id!)
        .order('created_at', ascending: false)
        .listen((data) {
      final docs = data.map((doc) {
        return NotificationModel.fromJson(doc);
      }).toList();
      
      docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifications.value = docs.take(30).toList();
      
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      isLoading.value = false;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final currentUser = profileController.currentUser.value;
    if (currentUser == null || currentUser.id == null) return;
    
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true})
        .eq('target_id', currentUser.id!)
        .eq('is_read', false);
  }

  static Future<void> triggerNotification({
    required String type,
    required String targetId,
    String? linkId,
    required String message,
  }) async {
    final pc = Get.find<ProfileController>();
    final me = pc.currentUser.value;
    if (me == null || me.id == targetId) return;
    await Supabase.instance.client.from('notifications').insert({
      'type': type,
      'sender_id': me.id,
      'sender_name': me.name,
      'sender_avatar': me.avatarUrl,
      'target_id': targetId,
      'link_id': linkId,
      'message': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'is_read': false,
    });
  }
}

