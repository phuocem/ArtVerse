import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/notification_controller.dart';
import '../../../data/models/notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundAura(lc),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(lc),
              _buildNotificationList(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          Positioned(
            top: 40,
            left: 40,
            child: CircleAvatar(
              backgroundColor: lc.cardColor.withValues(alpha: 0.8),
              child: IconButton(
                onPressed: () => Get.back<void>(),
                icon: Icon(MdiIcons.chevronLeft, color: lc.textColor, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAura(LayoutController lc) {
    return Container(decoration: BoxDecoration(color: lc.backgroundColor));
  }

  Widget _buildHeader(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 100, 40, 32),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'notifications'.tr.toUpperCase(),
                  style: TextStyle(color: lc.primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  "Activity Hub",
                  style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 40, fontWeight: FontWeight.w400, letterSpacing: -0.5),
                ),
              ],
            ),
            _buildActionIcon(MdiIcons.checkAll, lc, () => controller.markAllAsRead()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(LayoutController lc) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }

      if (controller.notifications.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.bellOffOutline, size: 96, color: lc.subtextColor.withValues(alpha: 0.1)),
                const SizedBox(height: 24),
                Text(
                  "Your studio is quiet for now".toUpperCase(),
                  style: TextStyle(color: lc.subtextColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification, lc);
          },
          childCount: controller.notifications.length,
        ),
      );
    });
  }

  Widget _buildNotificationItem(NotificationModel n, LayoutController lc) {
    return GestureDetector(
      onTap: () {
        controller.markAsRead(n.id);
        if (n.type == 'follow') Get.toNamed<void>('/profile/${n.senderId}');
        if (n.type == 'message') Get.toNamed<void>('/chat/${n.linkId}', arguments: {'targetUserId': n.senderId});
        if (n.type == 'like') Get.toNamed<void>('/view/${n.linkId}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: lc.cardColor.withValues(alpha: n.isRead ? 0.4 : 0.8),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: n.isRead ? lc.textColor.withValues(alpha: 0.05) : lc.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            _buildNotificationIcon(n.type, lc),
            const SizedBox(width: 24),
            CircleAvatar(
              radius: 28,
              backgroundImage: n.senderAvatar != null ? CachedNetworkImageProvider(n.senderAvatar!) : null,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: lc.textColor, fontSize: 16, fontFamily: 'Lexend'),
                      children: [
                        TextSpan(text: n.senderName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        TextSpan(text: " ${n.message}", style: TextStyle(color: lc.textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('HH:mm - d MMM').format(n.timestamp),
                    style: TextStyle(color: lc.subtextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (n.isRead == false)
              Container(width: 8, height: 8, decoration: BoxDecoration(color: lc.primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.5), blurRadius: 8)])),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, LayoutController lc) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'like':
        iconData = MdiIcons.heartPulse;
        color = Colors.pinkAccent;
        break;
      case 'follow':
        iconData = MdiIcons.accountPlusOutline;
        color = lc.primaryColor;
        break;
      case 'message':
        iconData = MdiIcons.messageTextOutline;
        color = lc.primaryColor.withValues(alpha: 0.7);
        break;
      default:
        iconData = MdiIcons.bellRingOutline;
        color = lc.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildActionIcon(IconData icon, LayoutController lc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: lc.cardColor, shape: BoxShape.circle, border: Border.all(color: lc.textColor.withValues(alpha: 0.05))),
        child: Icon(icon, color: lc.textColor, size: 22),
      ),
    );
  }
}
