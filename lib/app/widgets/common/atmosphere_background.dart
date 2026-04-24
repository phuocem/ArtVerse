import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/layout/controllers/layout_controller.dart';

class AtmosphereBackground extends StatefulWidget {
  final Widget child;
  const AtmosphereBackground({super.key, required this.child});

  @override
  State<AtmosphereBackground> createState() => _AtmosphereBackgroundState();
}

class _AtmosphereBackgroundState extends State<AtmosphereBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = List.generate(15, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Stack(
      children: [
        
        IgnorePointer(
          child: Obx(() => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lc.isDark.value ? const Color(0xFF020205) : const Color(0xFFECE9E6),
                  lc.isDark.value ? const Color(0xFF0A0A1F) : const Color(0xFFFFFFFF),
                  lc.isDark.value ? const Color(0xFF050510) : const Color(0xFFEFEFBB),
                ],
              ),
            ),
          )),
        ),

        
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                  color: lc.primaryColor.withValues(alpha: 0.1),
                ),
                child: Container(),
              );
            },
          ),
        ),

        
        widget.child,
      ],
    );
  }
}

class Particle {
  late double x, y, size, speed;
  late double angle;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 4 + 2;
    speed = math.Random().nextDouble() * 0.002 + 0.0005;
    angle = math.Random().nextDouble() * math.pi * 2;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({required this.particles, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final p in particles) {
      final x = (p.x * size.width + math.cos(progress * math.pi * 2 + p.angle) * 20) % size.width;
      final y = (p.y * size.height + math.sin(progress * math.pi * 2 + p.angle) * 20 + progress * size.height * p.speed * 100) % size.height;
      
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
