import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_widgets.dart';
class StudioSidebarExport extends StatelessWidget {
  final DrawController controller;
  const StudioSidebarExport({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel('XUẤT FRAME', accent: DS.cyan),
          _exportCard(
            Icons.image_rounded,
            'PNG – Frame hiện tại',
            'Xuất frame ${controller.currentFrameIndex.value + 1} dưới dạng PNG',
            DS.cyan,
            () => controller.exportFrameAsImage(controller.currentFrameIndex.value),
          ),
          _exportCard(
            Icons.photo_library_rounded,
            'PNG – Tất cả frame',
            'Xuất toàn bộ frame thành files PNG',
            DS.violet,
            controller.renderAllFramesToImages,
          ),
          sectionLabel('VIDEO & ANIMATION', accent: DS.gold),
          _exportCard(
            Icons.movie_rounded,
            'Xuất Video (MP4)',
            'Xuất toàn bộ frame thành video MP4',
            DS.gold,
            controller.exportToMp4,
          ),
          _exportCard(
            Icons.gif_box_rounded,
            'Xuất Ảnh động (GIF)',
            'Xuất toàn bộ frame thành ảnh động GIF',
            DS.gold,
            controller.exportToGif,
          ),
          const SizedBox(height: 20),
          sectionLabel('CHIA SẺ', accent: DS.rose),
          _exportCard(
            Icons.share_rounded,
            'Chia sẻ tác phẩm',
            'Đăng lên Portfolio ArtVerse',
            DS.rose,
            controller.showCommunityShareDialog,
          ),
          const SizedBox(height: 20),
          sectionLabel('THÔNG TIN', accent: DS.textDim),
          _infoRow('Kích thước', '1920 × 1080', DS.cyan),
          _infoRow('DPI', '72', DS.cyan),
          Obx(() =>
              _infoRow('Frames', '${controller.frames.length}', DS.gold)),
          Obx(() =>
              _infoRow('Layers', '${controller.layers.length}', DS.violet)),
          Obx(() => _infoRow(
              'FPS', '${controller.playbackSpeed.value}', DS.mint)),
        ],
      ),
    );
  }
  Widget _exportCard(IconData icon, String title, String subtitle,
      Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.05),
          borderRadius: DS.r12,
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: DS.r10,
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: DS.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: DS.textDim, fontSize: 10)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: accent.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
  Widget _infoRow(String label, String value, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r10,
          border: Border.all(color: DS.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: DS.textDim, fontSize: 11)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: DS.r6,
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Text(value,
                style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}