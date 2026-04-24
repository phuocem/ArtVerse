import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../data/models/message_model.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/chat_room_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundAura(lc),
          Column(
            children: [
              _buildAppBar(lc, profileController),
              Expanded(child: _buildMessageList(lc)),
              _buildInputArea(lc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAura(LayoutController lc) {
    return Container(decoration: BoxDecoration(color: lc.backgroundColor));
  }

  Widget _buildAppBar(LayoutController lc, ProfileController profileController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
      decoration: BoxDecoration(
        color: lc.cardColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
      ),
      child: FutureBuilder(
        future: profileController.getUser(controller.targetUserId, showLoading: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final user = snapshot.data!;
          return Row(
            children: [
              IconButton(onPressed: () => Get.back<void>(), icon: Icon(MdiIcons.chevronLeft, color: lc.textColor, size: 24)),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 16)),
                  Text("Online Artist", style: TextStyle(color: lc.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(LayoutController lc) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        reverse: true,
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          final isMe = message.senderId == controller.profileController.currentUser.value?.id;
          return _buildMessageBubble(message, isMe, lc);
        },
      );
    });
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, LayoutController lc) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: Get.width * 0.4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? lc.primaryColor : lc.cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.content,
              style: TextStyle(color: isMe ? Colors.white : lc.textColor, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.timestamp),
              style: TextStyle(color: (isMe ? Colors.white : lc.subtextColor).withValues(alpha: 0.5), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(LayoutController lc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      decoration: BoxDecoration(
        color: lc.cardColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: lc.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: controller.messageController,
                style: TextStyle(color: lc.textColor),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: lc.subtextColor.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => controller.sendMessage(),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: lc.primaryColor,
              child: Icon(MdiIcons.sendVariant, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
