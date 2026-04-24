import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/profile/controllers/profile_controller.dart';

class TopUpDialog extends StatelessWidget {
  final LayoutController lc;
  final ProfileController controller;

  const TopUpDialog({super.key, required this.lc, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: lc.backgroundColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: lc.textColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 48),
            const SizedBox(height: 24),
            const Text("Nạp ArtCoins", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [50, 100, 200, 500].map((amount) {
                return GestureDetector(
                  onTap: () {
                    controller.topUp(amount.toDouble());
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: lc.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lc.textColor.withValues(alpha: 0.1)),
                    ),
                    child: Text("+$amount", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
          ],
        ),
      ),
    );
  }
}
