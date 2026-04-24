import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../layout/controllers/layout_controller.dart';
import 'dialogs/top_up_dialog.dart';

class StudioUpgradeView extends GetView<ProfileController> {
  const StudioUpgradeView({super.key});
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundAura(lc),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(lc),
              _buildFeaturesGrid(lc),
              _buildPricingCard(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          Positioned(
            top: 40, left: 40,
            child: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close_rounded, color: lc.textColor, size: 32)),
          ),
        ],
      ),
    );
  }
  Widget _buildBackgroundAura(LayoutController lc) {
    return Container(
      decoration: BoxDecoration(color: lc.backgroundColor),
      child: Stack(
        children: [
          Positioned(
            top: -200, right: -200,
            child: Container(width: 600, height: 600, decoration: BoxDecoration(shape: BoxShape.circle, color: lc.primaryColor.withValues(alpha: 0.15)), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container())),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(80, 100, 80, 60),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(gradient: lc.accentGradient, borderRadius: BorderRadius.circular(40)), child: const Text("ARTVERSE STUDIO ADVANCED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2))),
            const SizedBox(height: 24),
            Text("Unlock Creative Potential", textAlign: TextAlign.center, style: TextStyle(color: lc.textColor, fontSize: 64, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: -2)),
            const SizedBox(height: 16),
            Text("Experience the next generation of creative tools with Studio Advanced.", style: TextStyle(color: lc.subtextColor, fontSize: 18, fontFamily: 'Lexend')),
          ],
        ),
      ),
    );
  }
  Widget _buildFeaturesGrid(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 30, crossAxisSpacing: 30, childAspectRatio: 1.2),
        delegate: SliverChildListDelegate([
          _buildFeatureCard(Icons.brush_rounded, "Advanced Tools", "Unlock studio-grade brushes and creative instruments.", lc),
          _buildFeatureCard(Icons.cloud_done_rounded, "Cloud Sync", "Save and collaborate on your projects across all devices.", lc),
          _buildFeatureCard(Icons.hd_rounded, "8K Export", "Export your masterpieces in ultra-high resolution for portfolio.", lc),
        ]),
      ),
    );
  }
  Widget _buildFeatureCard(IconData icon, String title, String desc, LayoutController lc) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: lc.cardColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(32), border: Border.all(color: lc.textColor.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: lc.primaryColor, size: 40),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(color: lc.textColor, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(color: lc.subtextColor, fontSize: 14, fontFamily: 'Lexend', height: 1.5)),
        ],
      ),
    );
  }
  Widget _buildPricingCard(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(80, 80, 80, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [lc.primaryColor.withValues(alpha: 0.1), lc.accentColor.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(48), border: Border.all(color: lc.primaryColor.withValues(alpha: 0.2))),
          child: Column(
            children: [
              Text("Unlimited Studio Access", style: TextStyle(color: lc.textColor, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("50.0", style: TextStyle(color: lc.textColor, fontSize: 80, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: -4)),
                  Padding(padding: const EdgeInsets.only(bottom: 16, left: 8), child: Text("ArtCoins / Once", style: TextStyle(color: lc.primaryColor, fontSize: 18, fontWeight: FontWeight.w900))),
                ],
              ),
              const SizedBox(height: 48),
              Obx(() {
                final balance = controller.currentUser.value?.balance ?? 0.0;
                return Column(
                  children: [
                    Text("Your Balance: ${balance.toStringAsFixed(1)} ArtCoins", style: TextStyle(color: lc.subtextColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton("Top Up Coins", lc.cardColor, lc.textColor, () => _showTopUpDialog(lc), lc),
                        const SizedBox(width: 20),
                        _buildButton("Upgrade Now", lc.primaryColor, Colors.white, () => controller.upgradeToStudio(), lc, isLarge: true),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButton(String label, Color color, Color textColor, VoidCallback onTap, LayoutController lc, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isLarge ? 48 : 32, vertical: 20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: [if (isLarge) BoxShadow(color: lc.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Lexend')),
      ),
    );
  }
  void _showTopUpDialog(LayoutController lc) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: lc.backgroundColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: lc.textColor.withValues(alpha: 0.1))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 24),
              const Text("Nạp ArtCoins", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16, runSpacing: 16,
                children: [50, 100, 200, 500].map((amount) {
                  return GestureDetector(
                    onTap: () { controller.topUp(amount.toDouble()); Get.back(); },
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), decoration: BoxDecoration(color: lc.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: lc.textColor.withValues(alpha: 0.1))), child: Text("+$amount", style: const TextStyle(fontWeight: FontWeight.bold))),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
            ],
          ),
        ),
      ),
    );
  }
}
