import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../controllers/ai_draw_controller.dart';
import '../widgets/studio_widgets.dart';
class StudioAiDialog extends StatefulWidget {
  const StudioAiDialog({super.key});
  @override
  State<StudioAiDialog> createState() => _StudioAiDialogState();
}
class _StudioAiDialogState extends State<StudioAiDialog> {
  late final DrawController _drawCtrl;
  final TextEditingController _textCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    Get.put(AiDrawController());
    _drawCtrl = Get.find<DrawController>();
  }
  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DS.card,
      shape: RoundedRectangleBorder(
          borderRadius: DS.r24, side: BorderSide(color: DS.border)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: DS.rose.withValues(alpha: 0.12),
                      borderRadius: DS.r12),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: DS.rose, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI STUDIO',
                        style: TextStyle(
                            color: DS.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1)),
                    Text('Tạo palette từ mô tả',
                        style: TextStyle(color: DS.textDim, fontSize: 10)),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: DS.r50,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded,
                        color: DS.textDim, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  color: DS.surface,
                  borderRadius: DS.r12,
                  border: Border.all(color: DS.border)),
              child: TextField(
                controller: _textCtrl,
                style: TextStyle(color: DS.text, fontSize: 13),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Mô tả cảnh muốn vẽ... (vd: "hoàng hôn trên biển", "rừng nhiệt đới")',
                  hintStyle: TextStyle(color: DS.textDim, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                'Hoàng hôn', 'Đại dương', 'Rừng xanh',
                'Cyberpunk', 'Vũ trụ', 'Sakura',
              ].map((p) {
                return GestureDetector(
                  onTap: () => _textCtrl.text = p,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DS.rose.withValues(alpha: 0.06),
                      borderRadius: DS.r50,
                      border:
                          Border.all(color: DS.rose.withValues(alpha: 0.25)),
                    ),
                    child: Text(p,
                        style: TextStyle(
                            color: DS.rose, fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final palette = _drawCtrl.aiGeneratedPalette;
              if (palette.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PALETTE TẠO RA',
                      style: TextStyle(
                          color: DS.textDim,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: palette.map((c) {
                      final isSel = _drawCtrl.selectedColor.value
                              .toARGB32() ==
                          c.toARGB32();
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _drawCtrl.changeColor(c);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 40,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: DS.r8,
                              border: Border.all(
                                  color: isSel ? Colors.white : Colors.transparent,
                                  width: 2),
                              boxShadow: isSel
                                  ? DS.glowShadow(c, radius: 10)
                                  : null,
                            ),
                            child: isSel
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Huỷ',
                        style: TextStyle(color: DS.textDim)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                        gradient: DS.crimsonGrad, borderRadius: DS.r12),
                    child: TextButton(
                      onPressed: () {
                        if (_textCtrl.text.isNotEmpty) {
                          _drawCtrl.generatePaletteFromAI(_textCtrl.text);
                        }
                      },
                      child: const Text('✦ Tạo Palette',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}