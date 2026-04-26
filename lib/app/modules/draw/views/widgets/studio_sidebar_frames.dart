import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_widgets.dart';
class StudioSidebarFrames extends StatelessWidget {
  final DrawController controller;
  const StudioSidebarFrames({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(controller: controller),
        Expanded(child: _FrameGrid(controller: controller)),
        _Footer(controller: controller),
      ],
    );
  }
}
class _Header extends StatelessWidget {
  final DrawController controller;
  const _Header({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DS.border))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.movie_rounded, size: 13, color: DS.gold),
              const SizedBox(width: 6),
              const Text('TIMELINE',
                  style: TextStyle(
                      color: DS.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
              const Spacer(),
              Obx(() => Text('${controller.frames.length} frames',
                  style: const TextStyle(
                      color: DS.textDim, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _FpsSelector(controller: controller),
              const Spacer(),
              Obx(() => _iconToggle(
                    Icons.layers_rounded,
                    controller.onionSkinEnabled.value,
                    DS.cyan,
                    'Onion Skin',
                    () => controller.onionSkinEnabled.toggle(),
                  )),
              const SizedBox(width: 4),
              Obx(() => _playBtn(controller)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _iconToggle(IconData icon, bool active, Color accent,
      String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: DS.r8,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? accent.withValues(alpha: 0.14) : DS.card,
            borderRadius: DS.r8,
            border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.4)
                    : DS.border),
          ),
          alignment: Alignment.center,
          child: Icon(icon,
              size: 14, color: active ? accent : DS.textDim),
        ),
      ),
    );
  }
  Widget _playBtn(DrawController c) {
    final isPlay = c.isPlaying.value;
    return InkWell(
      onTap: c.togglePlayback,
      borderRadius: DS.r50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: isPlay ? DS.goldGrad : DS.violetGrad,
          shape: BoxShape.circle,
          boxShadow: DS.glowShadow(isPlay ? DS.gold : DS.violet, radius: 8),
        ),
        child: Icon(
          isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
class _FpsSelector extends StatelessWidget {
  final DrawController controller;
  const _FpsSelector({required this.controller});
  static const _fpsOptions = [4, 6, 8, 12, 24];
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: DS.card,
      shape: RoundedRectangleBorder(
          borderRadius: DS.r12,
          side: BorderSide(color: DS.border)),
      onSelected: controller.setFps,
      itemBuilder: (_) => _fpsOptions
          .map((v) => PopupMenuItem(
                value: v,
                child: Text('$v FPS',
                    style: TextStyle(
                        color: v == controller.fps ? DS.violet : DS.text,
                        fontWeight: v == controller.fps
                            ? FontWeight.w700
                            : FontWeight.w400)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r8,
          border: Border.all(color: DS.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed_rounded, size: 11, color: DS.textDim),
            const SizedBox(width: 4),
            Obx(() => Text(
                  '${controller.playbackSpeed.value} FPS',
                  style: const TextStyle(
                      color: DS.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                )),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down_rounded,
                size: 14, color: DS.textDim),
          ],
        ),
      ),
    );
  }
}
class _FrameGrid extends StatelessWidget {
  final DrawController controller;
  const _FrameGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 16 / 9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: controller.frames.length,
          itemBuilder: (_, i) => _FrameTile(
            index: i,
            controller: controller,
            isSelected: controller.currentFrameIndex.value == i,
          ),
        ));
  }
}
class _FrameTile extends StatelessWidget {
  final int index;
  final DrawController controller;
  final bool isSelected;
  const _FrameTile(
      {required this.index,
      required this.controller,
      required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectFrame(index),
      onLongPress: () => _showFrameMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: DS.r10,
          border: Border.all(
              color: isSelected ? DS.violet : DS.border,
              width: isSelected ? 2 : 1),
          boxShadow: isSelected ? DS.glowShadow(DS.violet, radius: 12) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 8 : 9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder(
                future: controller.renderThumbnail(index),
                builder: (_, snap) => snap.hasData && snap.data!.isNotEmpty
                    ? Image.memory(snap.data!, fit: BoxFit.cover,
                        gaplessPlayback: true)
                    : Container(
                        color: DS.surface,
                        child: const Center(
                          child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: DS.violet)),
                        ),
                      ),
              ),
              if (isSelected)
                Positioned.fill(
                    child: Container(
                        color: DS.violet.withValues(alpha: 0.08))),
              Positioned(
                bottom: 4,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: DS.r4,
                  ),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace')),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: DS.crimson.withValues(alpha: 0.85),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showFrameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DS.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                decoration: const BoxDecoration(
                    color: DS.border, borderRadius: DS.r4)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: DS.cyan, size: 20),
              title: const Text('Nhân đôi frame',
                  style: TextStyle(
                      color: DS.cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.duplicateFrame(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_rounded,
                  color: DS.gold, size: 20),
              title: const Text('Sao chép frame',
                  style: TextStyle(
                      color: DS.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.copyFrame(index);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: DS.crimson, size: 20),
              title: const Text('Xoá frame',
                  style: TextStyle(
                      color: DS.crimson,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _confirmDelete(BuildContext context) {
    if (controller.frames.length <= 1) {
      Get.snackbar('Không thể xoá', 'Phải có ít nhất 1 frame',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DS.card,
          colorText: DS.text);
      return;
    }
    controller.deleteCurrentFrame();
  }
}
class _Footer extends StatelessWidget {
  final DrawController controller;
  const _Footer({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: DS.border))),
      child: Row(
        children: [
          Expanded(
            child: _btn(Icons.add_rounded, 'Thêm Frame', DS.violet,
                controller.addFrame),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _btn(Icons.content_paste_rounded, 'Dán Frame', DS.gold,
                controller.pasteCopiedFrame),
          ),
        ],
      ),
    );
  }
  Widget _btn(
      IconData icon, String label, Color accent, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: DS.r10,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: DS.r10,
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: accent),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
