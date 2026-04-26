import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../controllers/collab_controller.dart';
import 'studio_widgets.dart';
import '../../../../data/models/draw/layer_model.dart';
class StudioSidebarLayers extends StatelessWidget {
  const StudioSidebarLayers({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<DrawController>();
    return Column(
      children: [
        _CollabBanner(),
        _LayerHeader(controller: c),
        Expanded(child: _LayerList(controller: c)),
        _LayerFooter(controller: c),
      ],
    );
  }
}
class _CollabBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      final collab = Get.find<CollabController>();
      return Obx(() {
        if (!collab.isCollaborating.value) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: DS.mint.withValues(alpha: 0.08),
            borderRadius: DS.r12,
            border: Border.all(color: DS.mint.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const PulsingDot(color: DS.mint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${collab.activeMembers.length} người đang vẽ',
                  style: const TextStyle(
                      color: DS.mint, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: collab.activeMembers.take(4).map((m) {
                  final color =
                      collab.memberColors[m['id']] ?? DS.violet;
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: -4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: DS.card, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        (m['name'] as String)[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
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
class _LayerHeader extends StatelessWidget {
  final DrawController controller;
  const _LayerHeader({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DS.border))),
      child: Row(
        children: [
          const Icon(Icons.layers_rounded, size: 14, color: DS.violet),
          const SizedBox(width: 6),
          const Text('LAYERS',
              style: TextStyle(
                  color: DS.violet,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const Spacer(),
          Obx(() => Text('${controller.layers.length} lớp',
              style:
                  const TextStyle(color: DS.textDim, fontSize: 10))),
        ],
      ),
    );
  }
}
class _LayerList extends StatelessWidget {
  final DrawController controller;
  const _LayerList({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          onReorder: (oldIdx, newIdx) {
            if (newIdx > oldIdx) newIdx--;
            controller.reorderLayer(oldIdx, newIdx);
          },
          buildDefaultDragHandles: false,
          itemCount: controller.layers.length,
          itemBuilder: (_, i) => _LayerTile(
            key: ValueKey('layer_$i'),
            index: i,
            layer: controller.layers[i],
            isSelected: controller.currentLayerIndex.value == i,
            controller: controller,
          ),
        ));
  }
}
class _LayerTile extends StatelessWidget {
  final int index;
  final LayerModel layer;
  final bool isSelected;
  final DrawController controller;
  const _LayerTile({
    super.key,
    required this.index,
    required this.layer,
    required this.isSelected,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    final accent = DS.violet;
    return GestureDetector(
      onTap: () => controller.switchLayer(index),
      onLongPress: () => _showLayerMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? accent.withValues(alpha: 0.1) : DS.card,
          borderRadius: DS.r12,
          border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.4)
                  : DS.border),
          boxShadow: isSelected ? DS.glowShadow(accent, radius: 10) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 14,
                      color: DS.textDim.withValues(alpha: 0.4)),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 20,
                  decoration: BoxDecoration(
                    color: DS.surface,
                    borderRadius: DS.r4,
                    border: Border.all(color: DS.border),
                  ),
                  child: FutureBuilder(
                    future: controller.renderThumbnail(
                        controller.currentFrameIndex.value, index),
                    builder: (_, snap) => snap.hasData && snap.data!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: DS.r4,
                            child: Image.memory(snap.data!,
                                fit: BoxFit.cover))
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    layer.name,
                    style: TextStyle(
                        color: isSelected ? DS.text : DS.textDim,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleLayerVisibility(index),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      layer.isVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 15,
                      color: layer.isVisible
                          ? DS.textDim
                          : DS.textDim.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.opacity_rounded,
                      size: 11, color: DS.textDim),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 10),
                        activeTrackColor: accent,
                        inactiveTrackColor: DS.border,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: layer.opacity.clamp(0.0, 1.0),
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) =>
                            controller.updateLayerOpacity(index, v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${(layer.opacity * 100).toInt()}%',
                      style: const TextStyle(
                          color: DS.textDim,
                          fontSize: 9,
                          fontFamily: 'monospace')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  void _showLayerMenu(BuildContext context) {
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
                    color: DS.border,
                    borderRadius: DS.r4)),
            const SizedBox(height: 12),
            _menuItem(Icons.drive_file_rename_outline_rounded,
                'Đổi tên', DS.violet, () => _renameDialog(context)),
            _menuItem(Icons.copy_rounded, 'Nhân đôi', DS.cyan,
                () => _duplicateLayer()),
            _menuItem(Icons.delete_rounded, 'Xoá lớp', DS.crimson,
                () => _deleteLayer()),
          ],
        ),
      ),
    );
  }
  Widget _menuItem(IconData icon, String label, Color accent,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: accent, size: 20),
      title: Text(label,
          style: TextStyle(
              color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }
  void _renameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: layer.name);
    Get.dialog(AlertDialog(
      backgroundColor: DS.card,
      shape: const RoundedRectangleBorder(borderRadius: DS.r16),
      title: const Text('Đổi tên lớp',
          style: TextStyle(color: DS.text, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        style: const TextStyle(color: DS.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: DS.surface,
          border: OutlineInputBorder(borderRadius: DS.r8),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('Huỷ',
                style: TextStyle(color: DS.textDim))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: DS.violet),
          onPressed: () {
            controller.renameLayer(index, ctrl.text.trim());
            Get.back();
          },
          child: const Text('Lưu'),
        ),
      ],
    ));
  }
  void _duplicateLayer() {
    controller.addLayer();
  }
  void _deleteLayer() {
    if (controller.layers.length <= 1) {
      Get.snackbar('Không thể xoá', 'Phải có ít nhất 1 lớp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DS.card,
          colorText: DS.text);
      return;
    }
    controller.frames[controller.currentFrameIndex.value].layers
        .removeAt(index);
    if (controller.currentLayerIndex.value >= controller.layers.length) {
      controller.currentLayerIndex.value = controller.layers.length - 1;
    }
    controller.updateBackgroundPicture();
    controller.frames.refresh();
  }
}
class _LayerFooter extends StatelessWidget {
  final DrawController controller;
  const _LayerFooter({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: DS.border))),
      child: Row(
        children: [
          Expanded(
            child: _footerBtn(
              Icons.add_rounded,
              'Thêm lớp',
              DS.violet,
              controller.addLayer,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Obx(() => _footerBtn(
                  Icons.merge_type_rounded,
                  'Gộp lớp',
                  DS.gold,
                  controller.layers.length > 1
                      ? () {
                          Get.snackbar('Gộp lớp',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: DS.card,
                              colorText: DS.text);
                        }
                      : () {},
                )),
          ),
        ],
      ),
    );
  }
  Widget _footerBtn(
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
