import 'package:flutter/material.dart';
import 'studio_widgets.dart';
import 'studio_canvas.dart';

class StudioCanvasContainer extends StatefulWidget {
  const StudioCanvasContainer({super.key});

  @override
  State<StudioCanvasContainer> createState() => _StudioCanvasContainerState();
}

class _StudioCanvasContainerState extends State<StudioCanvasContainer> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _glow, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: DS.violet.withValues(alpha: _glowAnim.value * 0.15), blurRadius: 60, spreadRadius: 10),
              BoxShadow(color: DS.crimson.withValues(alpha: _glowAnim.value * 0.06), blurRadius: 100, spreadRadius: 20),
              BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 40, spreadRadius: -10, offset: const Offset(0, 20)),
            ],
          ),
          child: child!,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: Container(
            width: 1050,
            height: 590.625,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: DS.borderHi, width: 1.5),
            ),
            child: const Stack(
              children: [
                Positioned.fill(child: StudioCanvas()),
                Positioned(
                  top: 0, left: 40, right: 40,
                  child: StudioGlareLine(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudioGlareLine extends StatelessWidget {
  const StudioGlareLine({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, DS.violet, Colors.transparent]),
      ),
    );
  }
}
