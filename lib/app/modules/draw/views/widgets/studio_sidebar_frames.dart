import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import '../../layout/controllers/layout_controller.dart';
import 'studio_widgets.dart';

class StudioSidebarFrames extends StatelessWidget {
  final DrawController controller;
  const StudioSidebarFrames({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: const BoxDecoration(color: DS.bg, border: Border(top: BorderSide(color: DS.border))),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildFilmstrip()),
          _buildAddButton(),
        ],
      ),
    ));
  }
  Widget _buildHeader() {
    return Container(
      height: 36, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DS.border))),
      child: Row(
        children: [
          const Icon(Icons.film_outlined, size: 13, color: DS.textDim),
          const SizedBox(width: 6),
          const Text('TIMELINE', style: TextStyle(color: DS.textDim, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2.5, fontFamily: 'monospace')),
          const SizedBox(width: 10),
          Obx(() => _badge('${controller.frames.length} FRAMES')),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: DS.card, borderRadius: DS.r8, border: Border.all(color: DS.border)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.speed_rounded, size: 11, color: DS.textDim), SizedBox(width: 4), Text('24 FPS', style: TextStyle(color: DS.textDim, fontSize: 9, fontWeight: FontWeight.w700, fontFamily: 'monospace'))])),
          const SizedBox(width: 8),
          Obx(() => InkWell(onTap: controller.togglePlay, borderRadius: DS.r50, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: controller.isPlaying.value ? DS.goldGrad : DS.violetGrad, shape: BoxShape.circle, boxShadow: DS.glowShadow(controller.isPlaying.value ? DS.gold : DS.violet, radius: 10)), child: Icon(controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 12)))),
        ],
      ),
    );
  }
  Widget _buildFilmstrip() {
    return Stack(
      children: [
        Positioned(top: 6, left: 0, right: 0, child: _perforations()),
        Positioned(bottom: 6, left: 0, right: 0, child: _perforations()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: ReorderableListView.builder(
            key: const PageStorageKey('frame_timeline'), onReorder: controller.reorderFrame, buildDefaultDragHandles: false, scrollController: controller.scrollController, scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), proxyDecorator: (child, _, anim) => Material(color: Colors.transparent, child: child), itemCount: controller.frames.length,
            itemBuilder: (_, index) => ReorderableDragStartListener(key: ValueKey('frame_$index'), index: index, child: _FrameTile(index: index, isSelected: controller.currentFrameIndex.value == index, controller: controller)),
          ),
        ),
      ],
    );
  }
  Widget _buildAddButton() {
    return Container(
      height: 36, decoration: const BoxDecoration(border: Border(top: BorderSide(color: DS.border))),
      child: Row(children: [Expanded(child: InkWell(onTap: controller.addFrame, child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, size: 14, color: DS.violet), SizedBox(width: 4), Text('THÊM FRAME', style: TextStyle(color: DS.violet, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5))]))))]),
    );
  }
  Widget _perforations() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(24, (_) => Container(width: 9, height: 6, decoration: BoxDecoration(color: DS.border.withValues(alpha: 0.6), borderRadius: DS.r4))));
  }
  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: DS.violet.withValues(alpha: 0.12), borderRadius: DS.r4, border: Border.all(color: DS.violet.withValues(alpha: 0.3))), child: Text(text, style: const TextStyle(color: DS.violet, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)));
}

class _FrameTile extends StatelessWidget {
  final int index;
  final bool isSelected;
  final DrawController controller;
  const _FrameTile({required this.index, required this.isSelected, required this.controller});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectFrame(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, width: 86, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: DS.r12, border: Border.all(color: isSelected ? DS.violet : DS.border, width: isSelected ? 2 : 1), boxShadow: isSelected ? DS.glowShadow(DS.violet, radius: 16) : null),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Stack(
            children: [
              FutureBuilder(future: controller.renderThumbnail(index), builder: (_, snap) => snap.hasData ? Image.memory(snap.data!, fit: BoxFit.cover, width: 86, height: double.infinity) : Container(color: DS.surface, child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: DS.violet))))),
              if (isSelected) Positioned.fill(child: Container(color: DS.violet.withValues(alpha: 0.08))),
              Positioned(bottom: 4, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: DS.r4), child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace')))),
              Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => controller.deleteFrame(index), child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: DS.crimson.withValues(alpha: 0.8), shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 8)))),
            ],
          ),
        ),
      ),
    );
  }
}
