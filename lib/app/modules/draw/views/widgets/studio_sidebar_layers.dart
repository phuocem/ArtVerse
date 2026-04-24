import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import '../controllers/collab_controller.dart';
import '../../layout/controllers/layout_controller.dart';
import 'studio_widgets.dart';
import '../../../data/models/draw/layer_model.dart';

class StudioSidebarLayers extends StatelessWidget {
  const StudioSidebarLayers({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();
    return Column(
      children: [
        _CollabStatus(controller: controller),
        _SidebarHeader(controller: controller),
        Expanded(
          child: Obx(() {
            final isAnim = controller.isAnimation.value;
            final showLayout = controller.isShowingLayout.value || !isAnim;
            return showLayout ? _LayerList(controller: controller) : _FrameListPanel(controller: controller);
          }),
        ),
        Obx(() {
          if (controller.isShowingLayout.value || !controller.isAnimation.value) return _AddLayerButton(controller: controller);
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class _CollabStatus extends StatelessWidget {
  final DrawController controller;
  const _CollabStatus({required this.controller});
  @override
  Widget build(BuildContext context) {
    try {
      final collab = Get.find<CollabController>();
      return Obx(() {
        if (!collab.isCollaborating.value) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: DS.mint.withValues(alpha: 0.08), borderRadius: DS.r12, border: Border.all(color: DS.mint.withValues(alpha: 0.3))),
          child: Row(
            children: [
              const PulsingDot(color: DS.mint),
              const SizedBox(width: 8),
              Expanded(child: Text('${collab.activeMembers.length} người đang vẽ', style: const TextStyle(color: DS.mint, fontSize: 11, fontWeight: FontWeight.w600))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: collab.activeMembers.take(4).map((m) {
                  final color = collab.memberColors[m['id']] ?? DS.violet;
                  return Container(width: 20, height: 20, margin: const EdgeInsets.only(left: -4), decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: DS.card, width: 1.5)), child: Center(child: Text((m['name'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))));
                }).toList(),
              ),
            ],
          ),
        );
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _SidebarHeader extends StatelessWidget {
  final DrawController controller;
  const _SidebarHeader({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Obx(() {
        final isAnim = controller.isAnimation.value;
        if (!isAnim) return sectionLabel('LAYERS', accent: DS.violet);
        return Container(
          height: 38, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: DS.card, borderRadius: DS.r12, border: Border.all(color: DS.border)),
          child: Row(children: [_tab('FRAMES', false, controller), const SizedBox(width: 3), _tab('LAYERS', true, controller)]),
        );
      }),
    );
  }
  Widget _tab(String label, bool isLayout, DrawController ctrl) {
    return Obx(() {
      final isSel = ctrl.isShowingLayout.value == isLayout;
      return Expanded(
        child: GestureDetector(
          onTap: () => ctrl.isShowingLayout.value = isLayout,
          child: AnimatedContainer(duration: const Duration(milliseconds: 250), decoration: BoxDecoration(gradient: isSel ? DS.violetGrad : null, borderRadius: DS.r10), alignment: Alignment.center, child: Text(label, style: TextStyle(color: isSel ? Colors.white : DS.textDim, fontSize: 10, fontWeight: isSel ? FontWeight.w900 : FontWeight.w500, letterSpacing: 1))),
        ),
      );
    });
  }
}

class _LayerList extends StatelessWidget {
  final DrawController controller;
  const _LayerList({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      onReorder: (oldIdx, newIdx) {
        if (newIdx > oldIdx) newIdx--;
        controller.reorderLayer(oldIdx, newIdx);
      },
      buildDefaultDragHandles: false,
      itemCount: controller.layers.length,
      itemBuilder: (_, i) => _LayerTile(key: ValueKey('layer_$i'), index: i, layer: controller.layers[i], isSelected: controller.currentLayerIndex.value == i, controller: controller),
    ));
  }
}

class _LayerTile extends StatelessWidget {
  final int index;
  final LayerModel layer;
  final bool isSelected;
  final DrawController controller;
  const _LayerTile({super.key, required this.index, required this.layer, required this.isSelected, required this.controller});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.switchLayer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: isSelected ? DS.violet.withValues(alpha: 0.1) : DS.card, borderRadius: DS.r12, border: Border.all(color: isSelected ? DS.violet.withValues(alpha: 0.4) : DS.border), boxShadow: isSelected ? DS.glowShadow(DS.violet, radius: 12) : null),
        child: Row(
          children: [
            ReorderableDragStartListener(index: index, child: Icon(Icons.drag_indicator_rounded, size: 14, color: DS.textDim.withValues(alpha: 0.4))),
            const SizedBox(width: 8),
            Container(
              width: 36, height: 22, decoration: BoxDecoration(color: DS.surface, borderRadius: DS.r4, border: Border.all(color: DS.border)),
              child: FutureBuilder(future: controller.renderThumbnail(index), builder: (_, snap) => snap.hasData ? ClipRRect(borderRadius: DS.r4, child: Image.memory(snap.data!, fit: BoxFit.cover)) : const SizedBox.shrink()),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(layer.name, style: TextStyle(color: isSelected ? DS.text : DS.textDim, fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
            GestureDetector(onTap: () => controller.toggleLayerVisibility(index), child: Icon(layer.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 16, color: DS.textDim)),
          ],
        ),
      ),
    );
  }
}

class _FrameListPanel extends StatelessWidget {
  final DrawController controller;
  const _FrameListPanel({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      itemCount: controller.frames.length,
      itemBuilder: (_, i) {
        final isSel = controller.currentFrameIndex.value == i;
        return GestureDetector(
          onTap: () => controller.selectFrame(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: isSel ? DS.gold.withValues(alpha: 0.1) : DS.card, borderRadius: DS.r12, border: Border.all(color: isSel ? DS.gold.withValues(alpha: 0.4) : DS.border)),
            child: Row(children: [
              Container(width: 36, height: 22, decoration: BoxDecoration(color: DS.surface, borderRadius: DS.r4, border: Border.all(color: DS.border)), child: ClipRRect(borderRadius: DS.r4, child: FutureBuilder(future: controller.renderThumbnail(i), builder: (_, snap) => snap.hasData ? Image.memory(snap.data!, fit: BoxFit.cover) : const SizedBox.shrink()))),
              const SizedBox(width: 10),
              Text('Frame ${i + 1}', style: TextStyle(color: isSel ? DS.text : DS.textDim, fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)),
              const Spacer(),
              if (isSel) const Icon(Icons.arrow_right_rounded, color: DS.gold, size: 18),
            ]),
          ),
        );
      },
    ));
  }
}

class _AddLayerButton extends StatelessWidget {
  final DrawController controller;
  const _AddLayerButton({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: InkWell(
        onTap: controller.addLayer, borderRadius: DS.r12,
        child: Container(
          height: 38, decoration: BoxDecoration(color: DS.card, borderRadius: DS.r12, border: Border.all(color: DS.border), gradient: LinearGradient(colors: [DS.violet.withValues(alpha: 0.04), DS.cyan.withValues(alpha: 0.04)])),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_rounded, size: 14, color: DS.violet), SizedBox(width: 6), Text('THÊM LỚP', style: TextStyle(color: DS.violet, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5))]),
        ),
      ),
    );
  }
}
