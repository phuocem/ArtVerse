import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../data/models/message_model.dart';
import '../../profile/controllers/profile_controller.dart';

class MessagingController extends GetxController {
  final profileController = Get.find<ProfileController>();
  final threads = <ThreadModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToThreads();
  }

  void _listenToThreads() {
    final currentUserId = profileController.currentUser.value?.id;
    if (currentUserId == null) {
      isLoading.value = false;
      return;
    }
    Supabase.instance.client
        .from('threads')
        .stream(primaryKey: ['id'])
        .eq('participant_ids', '{ "$currentUserId" }') 
        .order('last_timestamp', ascending: false)
        .listen((data) {
      
      final filteredData = data.where((doc) {
        final participants = List<String>.from(doc['participant_ids'] ?? []);
        return participants.contains(currentUserId);
      }).toList();

      threads.value = filteredData.map((doc) {
        return ThreadModel.fromJson(doc);
      }).toList();
      isLoading.value = false;
    });
  }

  Future<void> startChat(String targetUserId) async {
    final currentUserId = profileController.currentUser.value?.id;
    if (currentUserId == null || targetUserId == currentUserId) return;
    final threadId = _getThreadId(currentUserId, targetUserId);
    final doc = await Supabase.instance.client.from('threads').select().eq('id', threadId).maybeSingle();
    if (doc == null) {
      await Supabase.instance.client.from('threads').insert({
        'id': threadId,
        'participant_ids': [currentUserId, targetUserId],
        'last_message': 'Started a conversation',
        'last_timestamp': DateTime.now().toUtc().toIso8601String(),
        'unread_count': {currentUserId: 0, targetUserId: 0},
      });
    }
    Get.toNamed('/chat/$threadId', arguments: {'targetUserId': targetUserId});
  }

  String _getThreadId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}

