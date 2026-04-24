import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/marketplace/controllers/marketplace_controller.dart';

class MarketplaceHero extends GetView<MarketplaceController> {
  final LayoutController lc;

  const MarketplaceHero({
    super.key,
    required this.lc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: lc.primaryColor.withValues(alpha: 0.15), blurRadius: 60, offset: const Offset(0, 30)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [lc.backgroundColor, lc.backgroundColor.withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 56, bottom: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _glassBadge('SEASON PASS · 2026', lc.primaryColor, lc),
                const SizedBox(height: 24),
                Text(
                  'CYBERSPACE\nRIGGING STUDIO',
                  style: GoogleFonts.lexend(color: lc.textColor, fontSize: 64, fontWeight: FontWeight.w900, height: 0.9, letterSpacing: -2),
                ),
                const SizedBox(height: 16),
                Text('Studio-grade rigging templates and character bases.', style: TextStyle(color: lc.subtextColor, fontSize: 18, fontWeight: FontWeight.w400)),
                const SizedBox(height: 48),
                Row(
                  children: [
                    _gradientButton('EXPLORE VAULT', lc, () => controller.filterResources('All')),
                    const SizedBox(width: 20),
                    _outlineBtn('Watch Trailer', lc, onTap: () => Get.toNamed<void>('/community')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBadge(String label, Color color, LayoutController lc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
    ),
    child: Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
  );

  Widget _gradientButton(String label, LayoutController lc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: lc.onPrimaryColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, LayoutController lc, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    ),
  );
}
