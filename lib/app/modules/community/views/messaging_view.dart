import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/messaging_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MessagingView extends GetView<MessagingController> {
  const MessagingView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundAura(lc),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(lc),
              _buildThreadList(lc, profileController),
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
    return Container(
      decoration: BoxDecoration(color: lc.backgroundColor),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lc.primaryColor.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lc.primaryColor.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 100, 40, 32),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'messages'.tr.toUpperCase(),
              style: TextStyle(
                color: lc.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Artist Connect",
              style: GoogleFonts.cinzel(
                color: lc.textColor,
                fontSize: 40,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadList(LayoutController lc, ProfileController profileController) {
    return Obx(() {
      if (controller.isLoading.value) {
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSkeletonThreadTile(lc),
            childCount: 5,
          ),
        );
      }

      if (controller.threads.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.messageOffOutline, size: 64, color: lc.subtextColor.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text("No conversations yet", style: TextStyle(color: lc.subtextColor)),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final thread = controller.threads[index];
            final currentUserId = profileController.currentUser.value?.id;
            final targetUserId = thread.participantIds.firstWhere((id) => id != currentUserId);
            
            return FutureBuilder(
              future: profileController.getUser(targetUserId, showLoading: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final user = snapshot.data!;
                final unread = thread.unreadCount[currentUserId] ?? 0;

                return GestureDetector(
                  onTap: () => Get.toNamed<void>('/chat/${thread.id}', arguments: {'targetUserId': targetUserId}),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: lc.cardColor.withValues(alpha: unread > 0 ? 0.8 : 0.4),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: unread > 0 ? lc.primaryColor.withValues(alpha: 0.2) : lc.textColor.withValues(alpha: 0.05),
                        width: unread > 0 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      color: lc.textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(thread.lastTimestamp),
                                    style: TextStyle(color: lc.subtextColor, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                thread.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: unread > 0 ? lc.textColor : lc.subtextColor,
                                  fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: lc.primaryColor, shape: BoxShape.circle),
                            child: Text(
                              unread.toString(),
                              style: TextStyle(color: lc.onPrimaryColor, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          childCount: controller.threads.length,
        ),
      );
    });
  }
  Widget _buildSkeletonThreadTile(LayoutController lc) {
    return Shimmer.fromColors(
      baseColor: lc.cardColor.withValues(alpha: 0.4),
      highlightColor: lc.textColor.withValues(alpha: 0.05),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: lc.cardColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lc.textColor.withValues(alpha: 0.06),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: lc.textColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lc.textColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
