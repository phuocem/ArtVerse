import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import '../widgets/studio_widgets.dart';
import '../../../data/models/draw/drawn_line_model.dart';

class StudioPerspectiveSheet extends StatelessWidget {
  final DrawController controller;
  const StudioPerspectiveSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(color: DS.card, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), border: Border(top: BorderSide(color: DS.border))),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: DS.border, borderRadius: DS.r4))),
          const SizedBox(height: 20),
          sectionLabel('CHẾ ĐỘ PHỐI CẢNH', accent: DS.gold),
          const SizedBox(height: 4),
          Row(children: [
            _perspTile(PerspectiveType.none,       'NONE',  '—',      Icons.block_rounded,       DS.textDim),
            const SizedBox(width: 8),
            _perspTile(PerspectiveType.onePoint,   '1PT',   '1 điểm', Icons.looks_one_rounded,   DS.gold),
            const SizedBox(width: 8),
            _perspTile(PerspectiveType.twoPoint,   '2PT',   '2 điểm', Icons.looks_two_rounded,   DS.cyan),
            const SizedBox(width: 8),
            _perspTile(PerspectiveType.threePoint, '3PT',   '3 điểm', Icons.looks_3_rounded,     DS.violet),
          ]),
          const SizedBox(height: 20),
          if (controller.perspectiveType.value != PerspectiveType.none) ...[
            _snapRow(icon: Icons.linear_scale_rounded, title: 'Perspective Snap', subtitle: 'Bám vào đường phối cảnh', value: controller.isPerspectiveSnapping.value, accent: DS.gold, onChanged: (v) => controller.isPerspectiveSnapping.value = v),
            const SizedBox(height: 10),
          ],
          _snapRow(icon: Icons.grid_3x3_rounded, title: 'Isometric Snap', subtitle: 'Bám 3 trục 0° / 60° / 120°', value: controller.isIsometricSnapEnabled.value, accent: DS.mint, onChanged: (v) => controller.isIsometricSnapEnabled.value = v),
        ],
      )),
    );
  }

  Widget _perspTile(PerspectiveType mode, String label, String sub, IconData icon, Color c) {
    final isSel = controller.perspectiveType.value == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.perspectiveType.value = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: isSel ? c.withValues(alpha: 0.12) : DS.surface, borderRadius: DS.r16, border: Border.all(color: isSel ? c.withValues(alpha: 0.5) : DS.border, width: isSel ? 1.5 : 1), boxShadow: isSel ? DS.glowShadow(c, radius: 14) : null),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: isSel ? c : DS.textDim),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSel ? c : DS.textDim, letterSpacing: 1)),
            Text(sub, style: TextStyle(fontSize: 8, color: isSel ? c.withValues(alpha: 0.6) : DS.textDim)),
          ]),
        ),
      ),
    );
  }

  Widget _snapRow({required IconData icon, required String title, required String subtitle, required bool value, required Color accent, required ValueChanged<bool> onChanged}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: value ? accent.withValues(alpha: 0.08) : DS.surface, borderRadius: DS.r16, border: Border.all(color: value ? accent.withValues(alpha: 0.3) : DS.border)),
      child: Row(children: [
        Icon(icon, size: 18, color: value ? accent : DS.textDim),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: value ? DS.text : DS.textDim, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(color: DS.textDim, fontSize: 9)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: accent, activeTrackColor: accent.withValues(alpha: 0.3), inactiveTrackColor: DS.border, inactiveThumbColor: DS.textDim),
      ]),
    );
  }
}
