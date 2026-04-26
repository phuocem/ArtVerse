import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}
class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _bgAnim;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _tagOpacity;
  late Animation<double> _fadeOut;
  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4))
        .drive(Tween(begin: 0.0, end: 1.0));
    _tagOpacity = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.5, 1.0))
        .drive(Tween(begin: 0.0, end: 1.0));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeOut = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));
    _bgAnim = _bgCtrl;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (mounted) await _fadeCtrl.forward();
      if (mounted) {
        final session = Get.find<ProfileController>().isLogined.value;
        Get.offAllNamed<void>(session ? '/layout' : '/login');
      }
    });
  }
  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOut,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _bgAnim,
              builder: (_, __) => CustomPaint(
                painter: _MeshPainter(_bgAnim.value),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: _buildLogoMark(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: Text(
                      'ARTVERSE',
                      style: GoogleFonts.lexend(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _tagOpacity,
                    child: Text(
                      'CREATE WITHOUT LIMITS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _tagOpacity,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLogoMark() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: AppColors.violetPink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'A',
          style: GoogleFonts.lexend(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      _Orb(Offset(size.width * 0.15, size.height * 0.2), 220, AppColors.violet.withValues(alpha: 0.07), 0.0),
      _Orb(Offset(size.width * 0.8, size.height * 0.15), 180, AppColors.pink.withValues(alpha: 0.06), 0.33),
      _Orb(Offset(size.width * 0.5, size.height * 0.75), 260, AppColors.teal.withValues(alpha: 0.05), 0.66),
    ];
    for (final orb in orbs) {
      final phase = (t + orb.phase) % 1.0;
      final dx = math.sin(phase * math.pi * 2) * 30;
      final dy = math.cos(phase * math.pi * 2) * 20;
      final center = orb.center + Offset(dx, dy);
      canvas.drawCircle(
        center,
        orb.radius,
        Paint()
          ..color = orb.color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
      );
    }
  }
  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}
class _Orb {
  final Offset center;
  final double radius;
  final Color color;
  final double phase;
  const _Orb(this.center, this.radius, this.color, this.phase);
}
