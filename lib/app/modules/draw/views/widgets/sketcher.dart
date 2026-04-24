import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/draw/drawn_line_model.dart';
import '../controllers/draw_controller.dart';

class SketcherFull extends CustomPainter {
  final List<DrawnLine> mainLines;
  final Picture? backgroundPicture;
  final List<MapEntry<List<DrawnLine>, double>>? onionSkinLines;
  final DrawnLine? tempLine;
  final Color backgroundColor;
  final double opacity;
  final SymmetryType symmetryType;
  final Offset? lazyPoint;
  final Offset? actualPoint;
  final PerspectiveType perspectiveType;
  final List<Offset> vanishingPoints;

  SketcherFull({required this.mainLines, this.backgroundPicture, this.onionSkinLines, this.tempLine, this.backgroundColor = Colors.transparent, this.opacity = 1.0, this.symmetryType = SymmetryType.none, this.lazyPoint, this.actualPoint, this.perspectiveType = PerspectiveType.none, this.vanishingPoints = const []});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != Colors.transparent) canvas.drawColor(backgroundColor, BlendMode.srcOver);
    if (backgroundPicture != null) {
      canvas.drawPicture(backgroundPicture!);
    } else if (mainLines.isNotEmpty) {
      _drawLinesWithSymmetry(canvas, mainLines, opacity, size);
    }
    if (tempLine != null) _drawLinesWithSymmetry(canvas, [tempLine!], opacity, size);
    if (onionSkinLines != null) {
      for (final entry in onionSkinLines!) {
        _drawLinesWithSymmetry(canvas, entry.key, entry.value * opacity, size);
      }
    }
    if (perspectiveType != PerspectiveType.none) _drawPerspectiveGrid(canvas, size);
    if (lazyPoint != null && actualPoint != null && lazyPoint != actualPoint) _drawStabilizerString(canvas);
  }

  void _drawStabilizerString(Canvas canvas) {
    final paint = Paint()..color = Colors.blueAccent.withValues(alpha: 0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawLine(lazyPoint!, actualPoint!, paint);
    canvas.drawCircle(actualPoint!, 3, paint..style = PaintingStyle.fill);
    canvas.drawCircle(lazyPoint!, 2, paint..color = Colors.white);
  }

  void _drawPerspectiveGrid(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    switch (perspectiveType) {
      case PerspectiveType.onePoint: _drawOnePointPerspective(canvas, size); break;
      case PerspectiveType.twoPoint: _drawTwoPointPerspective(canvas, size); break;
      case PerspectiveType.threePoint: _drawThreePointPerspective(canvas, size); break;
      case PerspectiveType.none: break;
    }
    canvas.restore();
  }

  void _drawOnePointPerspective(Canvas canvas, Size size) {
    if (vanishingPoints.isEmpty) return;
    final vp = vanishingPoints[0];
    final horizonPaint = Paint()..color = Colors.amber.withValues(alpha: 0.5)..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, vp.dy), Offset(size.width, vp.dy), horizonPaint);
    final linePaint = Paint()..color = Colors.teal.withValues(alpha: 0.18)..strokeWidth = 0.8;
    const edgeSteps = 12;
    final edgePoints = <Offset>[];
    for (int i = 0; i <= edgeSteps; i++) edgePoints.add(Offset(size.width * i / edgeSteps, 0));
    for (int i = 0; i <= edgeSteps; i++) edgePoints.add(Offset(size.width * i / edgeSteps, size.height));
    for (int i = 1; i < edgeSteps; i++) edgePoints.add(Offset(0, size.height * i / edgeSteps));
    for (int i = 1; i < edgeSteps; i++) edgePoints.add(Offset(size.width, size.height * i / edgeSteps));
    for (final ep in edgePoints) canvas.drawLine(vp, ep, linePaint);
    final crossPaint = Paint()..color = Colors.teal.withValues(alpha: 0.1)..strokeWidth = 0.5;
    for (int i = 1; i <= 8; i++) {
      final t = i / 9.0;
      final x = size.width * t;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), crossPaint);
    }
    for (int i = 1; i <= 6; i++) {
      final yAbove = vp.dy - (vp.dy / 7) * i;
      final yBelow = vp.dy + ((size.height - vp.dy) / 7) * i;
      if (yAbove >= 0) canvas.drawLine(Offset(0, yAbove), Offset(size.width, yAbove), crossPaint);
      if (yBelow <= size.height) canvas.drawLine(Offset(0, yBelow), Offset(size.width, yBelow), crossPaint);
    }
    _drawVpHandle(canvas, vp, Colors.amber, '1');
  }

  void _drawTwoPointPerspective(Canvas canvas, Size size) {
    if (vanishingPoints.length < 2) return;
    final vp1 = vanishingPoints[0];
    final vp2 = vanishingPoints[1];
    final horizonY = (vp1.dy + vp2.dy) / 2;
    final horizonPaint = Paint()..color = Colors.amber.withValues(alpha: 0.5)..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, horizonY), Offset(size.width, horizonY), horizonPaint);
    final linePaint1 = Paint()..color = Colors.teal.withValues(alpha: 0.18)..strokeWidth = 0.7;
    final linePaint2 = Paint()..color = Colors.purple.withValues(alpha: 0.18)..strokeWidth = 0.7;
    const steps = 10;
    final allEdgePoints = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      allEdgePoints.add(Offset(size.width * i / steps, 0));
      allEdgePoints.add(Offset(size.width * i / steps, size.height));
      allEdgePoints.add(Offset(0, size.height * i / steps));
      allEdgePoints.add(Offset(size.width, size.height * i / steps));
    }
    for (final ep in allEdgePoints) {
      canvas.drawLine(vp1, ep, linePaint1);
      canvas.drawLine(vp2, ep, linePaint2);
    }
    final centerX = size.width / 2;
    final vertPaint = Paint()..color = Colors.white.withValues(alpha: 0.15)..strokeWidth = 1.0;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), vertPaint);
    _drawVpHandle(canvas, vp1, Colors.teal, 'L');
    _drawVpHandle(canvas, vp2, Colors.purple, 'R');
  }

  void _drawThreePointPerspective(Canvas canvas, Size size) {
    if (vanishingPoints.length < 3) return;
    final vp1 = vanishingPoints[0];
    final vp2 = vanishingPoints[1];
    final vp3 = vanishingPoints[2];
    final horizonY = (vp1.dy + vp2.dy) / 2;
    final horizonPaint = Paint()..color = Colors.amber.withValues(alpha: 0.4)..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, horizonY), Offset(size.width, horizonY), horizonPaint);
    final lp1 = Paint()..color = Colors.teal.withValues(alpha: 0.15)..strokeWidth = 0.6;
    final lp2 = Paint()..color = Colors.purple.withValues(alpha: 0.15)..strokeWidth = 0.6;
    final lp3 = Paint()..color = Colors.orange.withValues(alpha: 0.15)..strokeWidth = 0.6;
    const steps = 10;
    final allEdgePoints = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      allEdgePoints.add(Offset(size.width * i / steps, 0));
      allEdgePoints.add(Offset(size.width * i / steps, size.height));
      allEdgePoints.add(Offset(0, size.height * i / steps));
      allEdgePoints.add(Offset(size.width, size.height * i / steps));
    }
    for (final ep in allEdgePoints) {
      canvas.drawLine(vp1, ep, lp1);
      canvas.drawLine(vp2, ep, lp2);
      canvas.drawLine(vp3, ep, lp3);
    }
    _drawVpHandle(canvas, vp1, Colors.teal, 'L');
    _drawVpHandle(canvas, vp2, Colors.purple, 'R');
    _drawVpHandle(canvas, vp3, Colors.orange, 'Z');
  }

  void _drawVpHandle(Canvas canvas, Offset vp, Color color, String label) {
    final circlePaint = Paint()..color = color.withValues(alpha: 0.7)..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.white.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(vp, 8, circlePaint);
    canvas.drawCircle(vp, 8, borderPaint);
    final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, vp - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawLinesWithSymmetry(Canvas canvas, List<DrawnLine> lines, double opacity, Size size) {
    _drawLines(canvas, lines, opacity, size);
    if (symmetryType == SymmetryType.vertical || symmetryType == SymmetryType.both) {
      canvas.save(); canvas.translate(size.width, 0); canvas.scale(-1, 1); _drawLines(canvas, lines, opacity, size); canvas.restore();
    }
    if (symmetryType == SymmetryType.horizontal || symmetryType == SymmetryType.both) {
      canvas.save(); canvas.translate(0, size.height); canvas.scale(1, -1); _drawLines(canvas, lines, opacity, size); canvas.restore();
    }
    if (symmetryType == SymmetryType.both) {
      canvas.save(); canvas.translate(size.width, size.height); canvas.scale(-1, -1); _drawLines(canvas, lines, opacity, size); canvas.restore();
    }
    if (symmetryType == SymmetryType.radial4 || symmetryType == SymmetryType.radial8) {
      final int count = symmetryType == SymmetryType.radial4 ? 4 : 8;
      final center = Offset(size.width / 2, size.height / 2);
      for (int i = 1; i < count; i++) {
        canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(i * 2 * math.pi / count); canvas.translate(-center.dx, -center.dy); _drawLines(canvas, lines, opacity, size); canvas.restore();
      }
    }
  }

  final _sharedPaint = Paint()..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke..isAntiAlias = true;

  void _drawLines(Canvas canvas, List<DrawnLine> lines, double opacity, Size size) {
    for (final line in lines) {
      if (line.points.isEmpty) continue;
      final baseColor = Color(line.colorValue);
      _sharedPaint..color = baseColor.withValues(alpha: (baseColor.a * opacity).clamp(0.0, 1.0))..strokeWidth = line.width..maskFilter = null..strokeCap = StrokeCap.round..blendMode = BlendMode.values[line.blendModeIndex];
      if (line.hardness < 1.0) {
        final blurRadius = (1.0 - line.hardness) * line.width * 2;
        if (blurRadius > 0) _sharedPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
      }
      if (line.brushType == BrushType.airbrush && line.hardness == 1.0) {
        _sharedPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 0.5);
      } else if (line.brushType == BrushType.calligraphy) {
        _sharedPaint.strokeCap = StrokeCap.square;
      }
      if (line.text != null) { _drawText(canvas, line, opacity); continue; }
      if (line.isFill) { _drawFill(canvas, line, opacity, size); continue; }
      if (line.scatter > 0.0) {
        _drawScatter(canvas, line, _sharedPaint);
      } else if (line.vfxType == 'neon' || line.brushType == BrushType.neon) {
        _drawNeon(canvas, line, _sharedPaint, baseColor, opacity);
      } else if (line.vfxType == 'sparkle') {
        _drawSparkle(canvas, line, _sharedPaint, baseColor, opacity);
      } else if (line.vfxType == 'rainbow') {
        _drawRainbow(canvas, line, _sharedPaint, opacity);
      } else {
        if (line.brushType == BrushType.pencil) { _drawPencil(canvas, line, _sharedPaint); }
        else if (line.brushType == BrushType.marker) { _drawMarker(canvas, line, _sharedPaint); }
        else if (line.brushType == BrushType.pen) { _drawPen(canvas, line, _sharedPaint); }
        else if (line.brushType == BrushType.watercolor) { _drawWatercolor(canvas, line, _sharedPaint); }
        else if (line.brushType == BrushType.oil) { _drawOil(canvas, line, _sharedPaint); }
        else if (line.brushType == BrushType.charcoal) { _drawCharcoal(canvas, line, _sharedPaint); }
        else {
          if (line.points.length == 1) { _sharedPaint.style = PaintingStyle.fill; canvas.drawCircle(line.points[0], line.width / 2, _sharedPaint); _sharedPaint.style = PaintingStyle.stroke; }
          else { canvas.drawPath(line.path, _sharedPaint); }
        }
      }
    }
  }

  void _drawText(Canvas canvas, DrawnLine line, double opacity) {
    final textPainter = TextPainter(text: TextSpan(text: line.text, style: TextStyle(color: Color(line.colorValue).withValues(alpha: line.opacity * opacity), fontSize: line.width * 5, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, line.points.first);
  }

  void _drawFill(Canvas canvas, DrawnLine line, double opacity, Size size) {
    final paint = Paint()..color = Color(line.colorValue).withValues(alpha: line.opacity * opacity)..style = PaintingStyle.fill;
    if (line.points.length == 1) canvas.drawCircle(line.points[0], size.shortestSide, paint..maskFilter = MaskFilter.blur(BlurStyle.normal, size.shortestSide / 4));
  }

  void _drawPencil(Canvas canvas, DrawnLine line, Paint paint) {
    final random = math.Random(line.points.length);
    final pencilPaint = Paint()..color = paint.color.withValues(alpha: paint.color.a * 0.8)..strokeWidth = line.width * 0.8..strokeCap = StrokeCap.square..style = PaintingStyle.stroke;
    final path = Path();
    if (line.points.isNotEmpty) {
      path.moveTo(line.points[0].dx, line.points[0].dy);
      for (int i = 1; i < line.points.length; i++) {
        final jitterX = (random.nextDouble() - 0.5) * 0.5;
        final jitterY = (random.nextDouble() - 0.5) * 0.5;
        path.lineTo(line.points[i].dx + jitterX, line.points[i].dy + jitterY);
      }
    }
    canvas.drawPath(path, pencilPaint);
    canvas.save(); canvas.translate(0.5, 0.5); canvas.drawPath(path, pencilPaint..color = pencilPaint.color.withValues(alpha: 0.3)); canvas.restore();
  }

  void _drawMarker(Canvas canvas, DrawnLine line, Paint paint) {
    final markerPaint = Paint()..color = paint.color.withValues(alpha: paint.color.a * 0.4)..strokeWidth = line.width * 1.5..strokeCap = StrokeCap.square..strokeJoin = StrokeJoin.bevel..style = PaintingStyle.stroke..blendMode = BlendMode.multiply;
    canvas.drawPath(line.path, markerPaint);
  }

  void _drawPen(Canvas canvas, DrawnLine line, Paint paint) {
    final penPaint = Paint()..color = paint.color..strokeWidth = line.width..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawPath(line.path, penPaint);
  }

  void _drawWatercolor(Canvas canvas, DrawnLine line, Paint paint) {
    final baseColor = paint.color;
    final watercolorPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line.path, watercolorPaint..color = baseColor.withValues(alpha: baseColor.a * 0.2)..strokeWidth = line.width * 1.5..maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 0.4));
    canvas.drawPath(line.path, watercolorPaint..color = baseColor.withValues(alpha: baseColor.a * 0.4)..strokeWidth = line.width..maskFilter = null);
    final random = math.Random(line.points.length);
    final grainPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < line.points.length; i += 3) {
      if (random.nextDouble() > 0.6) {
        final p = line.points[i];
        grainPaint.color = baseColor.withValues(alpha: baseColor.a * 0.1);
        canvas.drawCircle(p + Offset(random.nextDouble() * 5, random.nextDouble() * 5), random.nextDouble() * line.width * 0.5, grainPaint);
      }
    }
  }

  void _drawOil(Canvas canvas, DrawnLine line, Paint paint) {
    final baseColor = paint.color;
    final oilPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..strokeWidth = line.width;
    canvas.drawPath(line.path, oilPaint..color = baseColor.withValues(alpha: 0.9));
    final random = math.Random(line.points.length);
    final highlightPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = line.width * 0.2..color = Colors.white.withValues(alpha: 0.2);
    for (int i = 0; i < line.points.length - 1; i++) {
        if (random.nextDouble() > 0.8) canvas.drawLine(line.points[i], line.points[i+1], highlightPaint);
    }
  }

  void _drawCharcoal(Canvas canvas, DrawnLine line, Paint paint) {
    final baseColor = paint.color;
    final random = math.Random(line.points.length);
    final charcoalPaint = Paint()..style = PaintingStyle.fill..color = baseColor.withValues(alpha: 0.6);
    for (final p in line.points) {
      final size = (0.5 + random.nextDouble()) * line.width;
      final opacity = 0.2 + random.nextDouble() * 0.4;
      charcoalPaint.color = baseColor.withValues(alpha: opacity);
      canvas.save(); canvas.translate(p.dx, p.dy); canvas.rotate(random.nextDouble() * math.pi); canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.6), charcoalPaint); canvas.restore();
    }
  }

  void _drawScatter(Canvas canvas, DrawnLine line, Paint paint) {
    paint.style = PaintingStyle.fill;
    final random = math.Random(line.colorValue + line.points.length);
    for (final p in line.points) {
      final offsetX = (random.nextDouble() - 0.5) * line.scatter * 100;
      final offsetY = (random.nextDouble() - 0.5) * line.scatter * 100;
      final dotScale = 0.5 + random.nextDouble();
      canvas.drawCircle(Offset(p.dx + offsetX, p.dy + offsetY), (line.width / 2) * dotScale, paint);
    }
    paint.style = PaintingStyle.stroke;
  }

  void _drawNeon(Canvas canvas, DrawnLine line, Paint paint, Color baseColor, double opacity) {
    paint.color = baseColor.withValues(alpha: 0.2 * opacity); paint.strokeWidth = line.width * 4; paint.maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 2); canvas.drawPath(line.path, paint);
    paint.color = baseColor.withValues(alpha: 0.5 * opacity); paint.strokeWidth = line.width * 2; paint.maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 0.5); canvas.drawPath(line.path, paint);
    paint.color = Colors.white.withValues(alpha: 0.9 * opacity); paint.strokeWidth = line.width * 0.5; paint.maskFilter = null; canvas.drawPath(line.path, paint);
  }

  void _drawSparkle(Canvas canvas, DrawnLine line, Paint paint, Color baseColor, double opacity) {
    canvas.drawPath(line.path, paint);
    final random = math.Random(line.points.length);
    final sparklePaint = Paint()..style = PaintingStyle.fill..color = Colors.white.withValues(alpha: 0.8 * opacity);
    for (int i = 0; i < line.points.length; i += 5) {
      if (random.nextDouble() > 0.7) {
        final p = line.points[i];
        final size = random.nextDouble() * 3 + 1;
        canvas.drawCircle(p, size, sparklePaint);
        canvas.drawCircle(p, size * 2, Paint()..color = baseColor.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      }
    }
  }

  void _drawRainbow(Canvas canvas, DrawnLine line, Paint paint, double opacity) {
    if (line.points.length < 2) return;
    for (int i = 0; i < line.points.length - 1; i++) {
        final hue = (i * 5) % 360;
        paint.color = HSLColor.fromAHSL(opacity, hue.toDouble(), 1.0, 0.5).toColor();
        canvas.drawLine(line.points[i], line.points[i+1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant SketcherFull old) {
    if (old.mainLines.length != mainLines.length) return true;
    if (old.backgroundPicture != backgroundPicture) return true;
    if (old.tempLine != tempLine) return true;
    if (old.opacity != opacity) return true;
    if (old.symmetryType != symmetryType) return true;
    if (old.onionSkinLines?.length != onionSkinLines?.length) return true;
    return false;
  }
}
