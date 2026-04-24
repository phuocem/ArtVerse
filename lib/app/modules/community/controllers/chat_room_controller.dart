import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/message_model.dart';
import '../../profile/controllers/profile_controller.dart';
import 'notification_controller.dart';

class ChatRoomController extends GetxController {
  final profileController = Get.find<ProfileController>();
  final String threadId;
  final String targetUserId;

  final messages = <MessageModel>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final isLoading = true.obs;

  ChatRoomController({required this.threadId, required this.targetUserId});

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
    _markAsRead();
  }

  void _listenToMessages() {
    Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(50)
        .listen((data) {
      messages.value = data.map((doc) {
        return MessageModel.fromJson(doc);
      }).toList();
      isLoading.value = false;
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = profileController.currentUser.value?.id;
    if (currentUserId == null) return;

    final supabase = Supabase.instance.client;
    
    
    await supabase.from('messages').insert({
      'thread_id': threadId,
      'sender_id': currentUserId,
      'content': text,
      'type': 'text',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    
    
    final thread = await supabase.from('threads').select('unread_count').eq('id', threadId).single();
    final counts = Map<String, dynamic>.from(thread['unread_count'] as Map? ?? {});
    counts[targetUserId] = (counts[targetUserId] as int? ?? 0) + 1;

    await supabase.from('threads').update({
      'last_message': text,
      'last_timestamp': DateTime.now().toUtc().toIso8601String(),
      'unread_count': counts,
    }).eq('id', threadId);

    messageController.clear();
    _scrollToBottom();
    await NotificationController.triggerNotification(
      type: 'message',
      targetId: targetUserId,
      linkId: threadId,
      message: "sent you a new message",
    );
  }

  Future<void> _markAsRead() async {
    final currentUserId = profileController.currentUser.value?.id;
    if (currentUserId == null) return;

    try {
      final supabase = Supabase.instance.client;
      final thread = await supabase.from('threads').select('unread_count').eq('id', threadId).single();
      final counts = Map<String, dynamic>.from(thread['unread_count'] as Map? ?? {});
      counts[currentUserId] = 0;

      await supabase.from('threads').update({
        'unread_count': counts,
      }).eq('id', threadId);
    } catch (e) {}
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

