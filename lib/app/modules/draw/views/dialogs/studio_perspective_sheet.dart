import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../../../data/models/draw/drawn_line_model.dart';
import '../widgets/studio_widgets.dart';
class StudioPerspectiveSheet extends StatelessWidget {
  final DrawController controller;
  const StudioPerspectiveSheet({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(
        color: DS.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: DS.border)),
      ),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                      color: DS.border, borderRadius: DS.r4),
                ),
              ),
              const SizedBox(height: 20),
              sectionLabel('CHẾ ĐỘ PHỐI CẢNH', accent: DS.gold),
              const SizedBox(height: 8),
              Row(
                children: [
                  _perspTile(PerspectiveType.none, 'NONE', 'Tắt',
                      Icons.block_rounded, DS.textDim),
                  const SizedBox(width: 8),
                  _perspTile(PerspectiveType.onePoint, '1PT', '1 điểm',
                      Icons.looks_one_rounded, DS.gold),
                  const SizedBox(width: 8),
                  _perspTile(PerspectiveType.twoPoint, '2PT', '2 điểm',
                      Icons.looks_two_rounded, DS.cyan),
                  const SizedBox(width: 8),
                  _perspTile(PerspectiveType.threePoint, '3PT', '3 điểm',
                      Icons.looks_3_rounded, DS.violet),
                ],
              ),
              const SizedBox(height: 20),
              if (controller.perspectiveType.value != PerspectiveType.none) ...[
                sectionLabel('PERSPECTIVE SNAP', accent: DS.gold),
                _snapRow(
                  icon: Icons.linear_scale_rounded,
                  title: 'Perspective Snap',
                  subtitle: 'Bám vào đường phối cảnh',
                  value: controller.isPerspectiveSnapping.value,
                  accent: DS.gold,
                  onChanged: (v) => controller.isPerspectiveSnapping.value = v,
                ),
                const SizedBox(height: 10),
              ],
              sectionLabel('LƯỚI ISOMETRIC', accent: DS.mint),
              _snapRow(
                icon: Icons.grid_3x3_rounded,
                title: 'Isometric Snap',
                subtitle: 'Bám 3 trục 0° / 60° / 120°',
                value: controller.isIsometricSnapEnabled.value,
                accent: DS.mint,
                onChanged: (v) => controller.isIsometricSnapEnabled.value = v,
              ),
              const SizedBox(height: 16),
              sectionLabel('ĐỐI XỨNG', accent: DS.violet),
              Row(
                children: [
                  _symTile(SymmetryType.none, 'Tắt', DS.textDim),
                  const SizedBox(width: 6),
                  _symTile(SymmetryType.horizontal, 'Ngang', DS.violet),
                  const SizedBox(width: 6),
                  _symTile(SymmetryType.vertical, 'Dọc', DS.cyan),
                  const SizedBox(width: 6),
                  _symTile(SymmetryType.both, 'Cả hai', DS.rose),
                  const SizedBox(width: 6),
                  _symTile(SymmetryType.radial4, 'R×4', DS.gold),
                  const SizedBox(width: 6),
                  _symTile(SymmetryType.radial8, 'R×8', DS.mint),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DS.violet,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: DS.r12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Xong',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          )),
    );
  }
  Widget _perspTile(PerspectiveType mode, String label, String sub,
      IconData icon, Color c) {
    final isSel = controller.perspectiveType.value == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.perspectiveType.value = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? c.withValues(alpha: 0.12) : DS.surface,
            borderRadius: DS.r16,
            border: Border.all(
                color: isSel ? c.withValues(alpha: 0.5) : DS.border,
                width: isSel ? 1.5 : 1),
            boxShadow: isSel ? DS.glowShadow(c, radius: 12) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSel ? c : DS.textDim),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSel ? c : DS.textDim,
                      letterSpacing: 1)),
              Text(sub,
                  style: TextStyle(
                      fontSize: 8,
                      color: isSel
                          ? c.withValues(alpha: 0.6)
                          : DS.textDim)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _snapRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? accent.withValues(alpha: 0.08) : DS.surface,
          borderRadius: DS.r16,
          border: Border.all(
              color: value ? accent.withValues(alpha: 0.3) : DS.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: value ? accent : DS.textDim),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: value ? DS.text : DS.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: DS.textDim, fontSize: 9)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 22,
              decoration: BoxDecoration(
                  color: value ? accent : DS.border, borderRadius: DS.r50),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _symTile(SymmetryType type, String label, Color c) {
    final isSel = controller.symmetryType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.symmetryType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? c.withValues(alpha: 0.12) : DS.surface,
            borderRadius: DS.r10,
            border: Border.all(
                color: isSel ? c.withValues(alpha: 0.5) : DS.border),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      isSel ? FontWeight.w900 : FontWeight.w500,
                  color: isSel ? c : DS.textDim)),
        ),
      ),
    );
  }
}
