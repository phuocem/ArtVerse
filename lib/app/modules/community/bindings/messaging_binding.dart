import 'package:get/get.dart';
import '../controllers/messaging_controller.dart';
import '../controllers/chat_room_controller.dart';

class MessagingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagingController>(() => MessagingController());
  }
}

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    final String threadId = Get.parameters['id'] ?? '';
    final String targetUserId = Get.arguments?['targetUserId'] ?? '';
    
    Get.lazyPut<ChatRoomController>(
      () => ChatRoomController(threadId: threadId, targetUserId: targetUserId),
    );
  }
}
