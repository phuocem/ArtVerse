import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_draw_controller.dart';
import '../widgets/studio_widgets.dart';

class StudioAiDialog extends StatelessWidget {
  const StudioAiDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final aiCtrl = Get.put(AiDrawController());
    final textCtrl = TextEditingController();
    return Dialog(
      backgroundColor: DS.card,
      shape: const RoundedRectangleBorder(borderRadius: DS.r24, side: BorderSide(color: DS.border)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: DS.rose.withValues(alpha: 0.12), borderRadius: DS.r12), child: const Icon(Icons.auto_awesome_rounded, color: DS.rose, size: 20)),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI SKETCH', style: TextStyle(color: DS.text, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                Text('Prompt → Drawing', style: TextStyle(color: DS.textDim, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: DS.surface, borderRadius: DS.r12, border: Border.all(color: DS.border)),
              child: TextField(
                controller: textCtrl,
                style: const TextStyle(color: DS.text, fontSize: 13),
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Mô tả hình muốn vẽ...', hintStyle: TextStyle(color: DS.textDim), border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: DS.textDim)))),
              const SizedBox(width: 8),
              Expanded(child: Container(
                height: 42,
                decoration: const BoxDecoration(gradient: DS.crimsonGrad, borderRadius: DS.r12),
                child: TextButton(
                  onPressed: () { aiCtrl.generateSketchFromPrompt(textCtrl.text); Get.back(); },
                  child: const Text('Tạo nét ✦', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
