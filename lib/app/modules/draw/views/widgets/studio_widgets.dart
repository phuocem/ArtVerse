import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../controllers/draw_controller.dart';
import '../../../../core/theme/app_colors.dart';
class DS {
  DS._();
  static const bg        = AppColors.bg;
  static const surface   = AppColors.surface;
  static const card      = AppColors.surface2;
  static const cardHi    = AppColors.surface2;
  static const border    = AppColors.border;
  static const borderHi  = AppColors.border;
  static const crimson   = AppColors.pink;
  static const gold      = AppColors.amber;
  static const cyan      = AppColors.teal;
  static const violet    = AppColors.violet;
  static const mint      = AppColors.teal;
  static const rose      = AppColors.pink;
  static const text      = AppColors.textPrimary;
  static const textDim   = AppColors.textTertiary;
  static const textFaint = AppColors.textSecondary;
  static const crimsonGrad  = AppColors.violetPink;
  static const goldGrad     = AppColors.goldGrad;
  static const violetGrad   = AppColors.violetPink;
  static const noirGrad     = AppColors.noirGrad;
  static const r4  = BorderRadius.all(Radius.circular(4));
  static const r6  = BorderRadius.all(Radius.circular(6));
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r10 = BorderRadius.all(Radius.circular(10));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r24 = BorderRadius.all(Radius.circular(24));
  static const r32 = BorderRadius.all(Radius.circular(32));
  static const r50 = BorderRadius.all(Radius.circular(50));
  static List<BoxShadow> glowShadow(Color color, {double radius = 20}) => [
    BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: radius, spreadRadius: -2),
    BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: radius * 2, spreadRadius: -4),
  ];
  static List<BoxShadow> get elevation => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 10)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
  ];
}
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.08,
    this.borderRadius = 20.0,
    this.border,
    this.shadows,
    this.gradient,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? DS.card.withValues(alpha: opacity * 5)
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: DS.border, width: 1),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
Widget iconButton(IconData icon, VoidCallback onTap,
    {bool isSelected = false,
    bool isGlass = true,
    Color? color,
    String? tooltip,
    double size = 18,
    double padding = 10}) {
  final accent = color ?? DS.violet;
  final btn = AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutBack,
    width: (size + padding * 2).clamp(36, 56),
    height: (size + padding * 2).clamp(36, 56),
    decoration: BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          : null,
      color: isSelected ? null : (isGlass ? DS.card : Colors.transparent),
      borderRadius: DS.r50,
      border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: 0.6)
              : DS.border,
          width: isSelected ? 1.5 : 1),
      boxShadow: isSelected ? DS.glowShadow(accent) : null,
    ),
    child:
        Icon(icon, size: size, color: isSelected ? Colors.white : DS.textDim),
  );
  final child = InkWell(
      onTap: onTap,
      borderRadius: DS.r50,
      splashColor: accent.withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      child: btn);
  if (tooltip != null && tooltip.isNotEmpty) {
    return Tooltip(
        message: tooltip,
        decoration: BoxDecoration(
            color: DS.cardHi,
            borderRadius: DS.r8,
            border: Border.all(color: DS.border)),
        textStyle: const TextStyle(
            color: DS.text, fontSize: 11, fontWeight: FontWeight.w500),
        child: child);
  }
  return child;
}
Widget sectionLabel(String text, {Color? accent}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
                color: accent ?? DS.violet, borderRadius: DS.r4)),
        const SizedBox(width: 8),
        Text(text.toUpperCase(),
            style: TextStyle(
                color: (accent ?? DS.violet).withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                fontFamily: 'monospace')),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: DS.border)),
      ],
    ),
  );
}
class StudioSlider extends StatelessWidget {
  final String label;
  final RxDouble value;
  final double min;
  final double max;
  final bool isPercent;
  final String suffix;
  final Color? accent;
  final ValueChanged<double>? onChanged;
  const StudioSlider(
    this.label,
    this.value,
    this.min,
    this.max, {
    super.key,
    this.isPercent = false,
    this.suffix = '',
    this.accent,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final c = accent ?? DS.violet;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: DS.textFaint,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8)),
              Obx(() => Text(
                    isPercent
                        ? '${(value.value * 100).toInt()}%'
                        : '${value.value.toInt()}$suffix',
                    style: const TextStyle(
                        color: DS.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace'),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: _GlowThumb(color: c),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: c,
                  inactiveTrackColor: DS.border,
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: value.value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged ?? (v) => value.value = v,
                ),
              )),
        ],
      ),
    );
  }
}
class _GlowThumb extends SliderComponentShape {
  final Color color;
  const _GlowThumb({required this.color});
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(16, 16);
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(
        center, 7, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(center, 4, Paint()..color = color);
  }
}
Widget roundedControl({
  required String label,
  required VoidCallback onMinus,
  required VoidCallback onPlus,
  Widget? trailing,
}) {
  return GlassContainer(
    borderRadius: 24,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniBtn(MdiIcons.minus, onMinus),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(minWidth: 36),
            alignment: Alignment.center,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: DS.text,
                    letterSpacing: 0.5))),
        _miniBtn(MdiIcons.plus, onPlus),
      ],
    ),
  );
}
Widget _miniBtn(IconData icon, VoidCallback onTap) {
  return InkWell(
      onTap: onTap,
      borderRadius: DS.r50,
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 14, color: DS.textDim)));
}
class ThumbnailItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Future<Uint8List> futureImage;
  final Uint8List? initialImageData;
  final Color borderColor;
  final bool? isHidden;
  final VoidCallback? onToggleVisibility;
  final double? opacity;
  final ValueChanged<double>? onOpacityChanged;
  final double borderRadius;
  const ThumbnailItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.futureImage,
    this.initialImageData,
    required this.borderColor,
    this.isHidden,
    this.onToggleVisibility,
    this.opacity,
    this.onOpacityChanged,
    this.borderRadius = 14.0,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
              color: isSelected ? borderColor : DS.border,
              width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? DS.glowShadow(borderColor, radius: 24)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder<Uint8List>(
                  future: futureImage,
                  initialData: initialImageData,
                  builder: (_, snap) {
                    if (snap.hasData && snap.data!.isNotEmpty) {
                      return Opacity(
                          opacity: isHidden == true ? 0.25 : 1.0,
                          child: Image.memory(snap.data!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true));
                    }
                    return Container(
                        color: DS.surface,
                        child: const Center(
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5, color: DS.violet))));
                  },
                ),
                if (isSelected)
                  Positioned.fill(
                      child: Container(
                          decoration: BoxDecoration(
                              color: borderColor.withValues(alpha: 0.08)))),
                if (isHidden == true)
                  const Center(
                      child: Icon(Icons.visibility_off_rounded,
                          color: Colors.white60, size: 20)),
                if (isSelected)
                  Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: borderColor, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 10))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AnimatedBadge extends StatelessWidget {
  final String text;
  final Color? color;
  const AnimatedBadge(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? DS.crimson;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: DS.r4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1)),
    );
  }
}
class PulsingDot extends StatefulWidget {
  final Color? color;
  final double size;
  const PulsingDot({super.key, this.color, this.size = 8});
  @override
  State<PulsingDot> createState() => _PulsingDotState();
}
class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? DS.mint;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          boxShadow: [
            BoxShadow(
                color: c.withValues(alpha: _anim.value * 0.7),
                blurRadius: 8,
                spreadRadius: 1)
          ],
        ),
      ),
    );
  }
}
class LayoutSelector extends StatelessWidget {
  const LayoutSelector({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
          controller.layers.length, (i) => _layerItem(controller, i)),
    );
  }
  Widget _layerItem(DrawController controller, int index) {
    return Obx(() {
      final isSel = controller.currentLayerIndex.value == index;
      return GestureDetector(
        onTap: () => controller.switchLayer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSel
                ? DS.violet.withValues(alpha: 0.12)
                : DS.surface,
            borderRadius: DS.r12,
            border: Border.all(
                color: isSel
                    ? DS.violet.withValues(alpha: 0.4)
                    : DS.border),
            boxShadow: isSel ? DS.glowShadow(DS.violet, radius: 16) : null,
          ),
          child: Row(
            children: [
              Icon(Icons.layers_rounded,
                  size: 18, color: isSel ? DS.violet : DS.textDim),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.layers.length > index
                      ? controller.layers[index].name
                      : 'Lớp ${index + 1}',
                  style: TextStyle(
                      color: isSel ? DS.text : DS.textDim,
                      fontSize: 13,
                      fontWeight: isSel
                          ? FontWeight.w700
                          : FontWeight.w400),
                ),
              ),
              if (isSel)
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: DS.violet, shape: BoxShape.circle)),
            ],
          ),
        ),
      );
    });
  }
}
