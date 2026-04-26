import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/models/draw/drawn_line_model.dart';
import '../../../data/models/draw/frame_model.dart';
import '../../../data/models/draw/layer_model.dart';
import '../../../data/services/database_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/controllers/upload_controller.dart';
import '../views/widgets/studio_widgets.dart';
import '../views/widgets/sketcher.dart';
import 'collab_controller.dart';
enum ToolType { brush, eraser, line, rectangle, circle, bucket, text }
enum GridType { dots, lines, isometric }
enum PerspectiveType { none, onePoint, twoPoint, threePoint }
class DrawController extends GetxController {
  final profileController = Get.find<ProfileController>();
  final repaintKey = GlobalKey();
  final scrollController = ScrollController();
  final undoStack = <List<List<DrawnLine>>>[].obs;
  final redoStack = <List<List<DrawnLine>>>[].obs;
  final selectedColor = Colors.black.obs;
  final recentColors = <Color>[].obs;
  final importedPalettes = <Map<String, dynamic>>[].obs;
  final ownedBrushes = <Map<String, dynamic>>[].obs;
  final selectedWidth = 4.0.obs;
  final selectedOpacity = 1.0.obs;
  final selectedHardness = 1.0.obs;
  final selectedScatter = 0.0.obs;
  Offset startPoint = Offset.zero;
  final isEraser = false.obs;
  final Map<int, GlobalKey> frameItemKeys = {};
  final isReorderMode = false.obs;
  void toggleReorderMode() => isReorderMode.toggle();
  final showOnionSkin = true.obs;
  final onionSkinEnabled = true.obs;
  final onionSkinRangeBefore = 2;
  final onionSkinRangeAfter = 1;
  final onionSkinCount = 2.obs;
  void toggleOnionSkin() => showOnionSkin.toggle();
  final frames = <FrameModel>[].obs;
  final currentFrameIndex = 0.obs;
  final currentLayerIndex = 0.obs;
  String? currentProjectId;
  String? currentProjectName;
  final isAnimation = false.obs;
  final isPlaying = false.obs;
  final isFrameListExpanded = true.obs;
  final isShowingLayout = false.obs;
  final isAiSidebarCollapsed = true.obs;
  final isCollabMode = false.obs;
  final playbackSpeed = 6.obs;
  final isChanged = false.obs;
  final aiGeneratedPalette = <Color>[].obs;
  final remoteCursors = <Offset>[].obs;
  Timer? _collabSimulationTimer;
  final RxBool isSidebarCollapsed = false.obs;
  final RxBool isToolbarCollapsed = false.obs;
  void toggleSidebar() => isSidebarCollapsed.toggle();
  void toggleToolbar() => isToolbarCollapsed.toggle();
  void toggleAiSidebar() => isAiSidebarCollapsed.toggle();
  final RxInt numberOfLayers = 3.obs;
  final RxBool showGrid = false.obs;
  final RxDouble gridSize = 50.0.obs;
  final Rx<Color> canvasBackgroundColor = Colors.white.obs;
  final gridType = GridType.dots.obs;
  final RxBool isRecordingTimelapse = false.obs;
  final RxList<Uint8List> timelapseFrames = <Uint8List>[].obs;
  final symmetryType = SymmetryType.none.obs;
  final selectedBrushType = BrushType.solid.obs;
  final selectedVFX = 'none'.obs;
  final RxBool isSmoothingEnabled = true.obs;
  final transformationController = TransformationController();
  final cursorPosition = Rx<Offset?>(null);
  final RxnString referenceImage = RxnString(null);
  final RxDouble referenceOpacity = 0.5.obs;
  final isZenMode = false.obs;
  final gridOpacity = 0.2.obs;
  final smoothingIntensity = 0.5.obs;
  final isMirroredHorizontal = false.obs;
  final isMirroredVertical = false.obs;
  final isCurrentlyDrawing = false.obs;
  Timer? _autoSaveTimer;
  final isStabilizerEnabled = false.obs;
  final stabilizerLength = 40.0.obs;
  final Rx<Offset?> lazyPoint = Rx<Offset?>(null);
  final Rx<Offset?> actualPoint = Rx<Offset?>(null);
  final perspectiveType = Rx<PerspectiveType>(PerspectiveType.none);
  final vanishingPoints = <Offset>[
    const Offset(200, 300),
    const Offset(850, 300),
    const Offset(525, 50),
  ].obs;
  final isPerspectiveSnapping = false.obs;
  final isIsometricSnapEnabled = false.obs;
  final draggingVpIndex = (-1).obs;
  final animationEasing = 'linear'.obs; 
  final frameDurationMs = 100.obs;
  final parentProjectId = Rxn<String>();
  final remixDepth = 0.obs;
  final selectedSpacing = 10.0.obs;
  final selectedAngle = 0.0.obs;
  void toggleZenMode() => isZenMode.toggle();
  void toggleHorizontalMirror() => isMirroredHorizontal.toggle();
  void toggleVerticalMirror() => isMirroredVertical.toggle();
  void zoomIn() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.25).clamp(0.05, 20.0);
    _applyZoom(newScale);
  }
  void zoomOut() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.25).clamp(0.05, 20.0);
    _applyZoom(newScale);
  }
  void resetZoom() {
    transformationController.value = Matrix4.identity();
    update();
  }
  void _applyZoom(double scale) {
    final current = transformationController.value;
    final currentScale = current.getMaxScaleOnAxis();
    final ratio = scale / currentScale;
    transformationController.value = current.clone()..scale(ratio, ratio);
    update();
  }
  Future<void> pickReferenceImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      referenceImage.value = result.files.single.path;
      isChanged.value = true;
    }
  }
  void startCollabSimulation() {
    _collabSimulationTimer?.cancel();
    _collabSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (!isCollabMode.value) return;
      if (remoteCursors.isEmpty) {
        remoteCursors.addAll([const Offset(300, 300), const Offset(600, 400)]);
      }
      for (int i = 0; i < remoteCursors.length; i++) {
        final randX = (math.Random().nextDouble() * 10) - 5;
        final randY = (math.Random().nextDouble() * 10) - 5;
        remoteCursors[i] = Offset(
          (remoteCursors[i].dx + randX).clamp(0, 2000),
          (remoteCursors[i].dy + randY).clamp(0, 1500),
        );
      }
    });
  }
  void generatePaletteFromAI(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains("cyan") || p.contains("ocean") || p.contains("biển") || p.contains("nước")) {
      aiGeneratedPalette.value = [
        const Color(0xFF00E5FF),
        const Color(0xFF00B0FF),
        const Color(0xFF0091EA),
        const Color(0xFF01579B),
        const Color(0xFFE0F7FA),
      ];
    } else if (p.contains("cyber") || p.contains("neon") || p.contains("đêm") || p.contains("tối")) {
      aiGeneratedPalette.value = [
        const Color(0xFFFF00FF),
        const Color(0xFF00FFFF),
        const Color(0xFFFFFF00),
        const Color(0xFF7000FF),
        const Color(0xFF0D0221),
      ];
    } else if (p.contains("nature") || p.contains("forest") || p.contains("rừng") || p.contains("cây")) {
      aiGeneratedPalette.value = [
        const Color(0xFF00C853),
        const Color(0xFF64DD17),
        const Color(0xFFAEEA00),
        const Color(0xFF1B5E20),
        const Color(0xFFF1F8E9),
      ];
    } else if (p.contains("sunset") || p.contains("nắng") || p.contains("chiều") || p.contains("vàng")) {
      aiGeneratedPalette.value = [
        const Color(0xFFFF6D00),
        const Color(0xFFFFAB00),
        const Color(0xFFFFD600),
        const Color(0xFFFF3D00),
        const Color(0xFFFFF3E0),
      ];
    } else if (p.contains("galaxy") || p.contains("vũ trụ") || p.contains("sao")) {
      aiGeneratedPalette.value = [
        const Color(0xFF311B92),
        const Color(0xFF4527A0),
        const Color(0xFF512DA8),
        const Color(0xFF673AB7),
        const Color(0xFFEDE7F6),
      ];
    } else {
      aiGeneratedPalette.value = [
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
        const Color(0xFFC084FC),
        const Color(0xFFE0E7FF),
        const Color(0xFFF5F3FF),
      ];
    }
    if (aiGeneratedPalette.isNotEmpty) {
      selectedColor.value = aiGeneratedPalette[0];
    }
  }
  void clearReferenceImage() => referenceImage.value = null;
  void resetCamera() {
    transformationController.value = Matrix4.identity();
  }
  @override
  void onInit() {
    super.onInit();
    Get.put<UploadController>(UploadController(), permanent: true);
    initDrawing();
    addFrame();
    selectFrame(0);
    isChanged.value = false;
    _loadImportedPalettes();
    _loadOwnedBrushes();
    _startAutoSaveTimer();
  }
  void _loadImportedPalettes() {
    final db = Get.find<DatabaseService>();
    final palettes = db.settingsBox.get('custom_palettes', defaultValue: <dynamic>[]);
    importedPalettes.assignAll(palettes.cast<Map<String, dynamic>>());
  }
  void _loadOwnedBrushes() {
    final db = Get.find<DatabaseService>();
    final brushes = db.settingsBox.get('owned_brushes', defaultValue: <dynamic>[]);
    ownedBrushes.assignAll(brushes.cast<Map<String, dynamic>>());
  }
  Future<void> initDrawing() async {
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "upload_frames"));
    if (framesDir.existsSync()) {
      await framesDir.delete(recursive: true);
    }
  }
  @override
  void onClose() {
    scrollController.dispose();
    transformationController.dispose();
    _thumbnailDebounceTimer?.cancel();
    _playbackTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.onClose();
  }
  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isChanged.value && currentProjectId != null) {
        saveProjectToHive(currentProjectId!, currentProjectName ?? "Untitled");
      }
    });
  }
  late final _box = Get.find<DatabaseService>().drawProjectBox;
  final Rx<ui.Picture?> currentBackgroundPicture = Rx<ui.Picture?>(null);
  final Map<int, ui.Picture> _layerCache = {};
  void _invalidateLayerCache(int index) {
    _layerCache.remove(index);
  }
  Future<void> saveProjectToHive(String projectId, String name) async {
    final project = DrawProjectModel(
      id: projectId,
      name: name,
      updatedAt: DateTime.now(),
      frames: frames.map((f) => f.copy()).toList(),
      isAnimation: isAnimation.value,
    );
    await _box.put(projectId, project);
  }
  void loadProject(String id) {
    final project = _box.get(id);
    if (project != null) {
      frames.assignAll(project.frames.map((f) => f.copy()).toList());
      currentFrameIndex.value = 0;
      currentLayerIndex.value = 0;
      currentProjectId = id;
      currentProjectName = project.name;
      isAnimation.value = project.isAnimation;
      updateBackgroundPicture();
    }
  }
  List<MapEntry<List<DrawnLine>, double>> getPreviousFramesLines() {
    final index = currentFrameIndex.value;
    final result = <MapEntry<List<DrawnLine>, double>>[];
    for (int i = 1; i <= onionSkinCount.value; i++) {
      final idx = index + i;
      if (idx >= 0 && idx < frames.length) {
        final lines =
            frames[idx].layers.expand((layer) => layer.lines).toList();
        final opacity =
            (1.0 - i / (onionSkinCount.value + 1)) *
            0.4;
        result.add(MapEntry(lines, opacity));
      }
    }
    return result;
  }
  List<DrawnLine>? getPreviousFrameLines() {
    final index = currentFrameIndex.value;
    if (index <= 0 || index >= frames.length) return null;
    final prevFrame = frames[index - 1];
    return prevFrame.layers.expand((layer) => layer.lines).toList();
  }
  List<MapEntry<List<DrawnLine>, double>> getMultiOnionLines() {
    final index = currentFrameIndex.value;
    final List<MapEntry<List<DrawnLine>, double>> onionLayers = [];
    for (int i = 1; i <= onionSkinRangeBefore; i++) {
      final prevIndex = index - i;
      if (prevIndex < 0) break;
      final lines =
          frames[prevIndex].layers.expand((layer) => layer.lines).toList();
      final double alpha = (1.0 - i / (onionSkinRangeBefore + 1)) * 0.5;
      onionLayers.add(MapEntry(lines, alpha));
    }
    return onionLayers;
  }
  List<MapEntry<List<DrawnLine>, double>> getOnionSkinLines() {
    final index = currentFrameIndex.value;
    final List<MapEntry<List<DrawnLine>, double>> onionLayers = [];
    for (int i = 1; i <= onionSkinCount.value; i++) {
      final nextIndex = index + i;
      if (nextIndex >= frames.length) break;
      final lines =
          frames[nextIndex].layers.expand((layer) => layer.lines).toList();
      final opacity = (1.0 - i / (onionSkinCount.value + 1)) * 0.4;
      onionLayers.add(MapEntry(lines, opacity));
    }
    return onionLayers;
  }
  Widget buildLayoutSelector() => const LayoutSelector();
  final Map<String, Uint8List> thumbnailCache = {};
  Timer? _playbackTimer;
  int _currentIndex = 0;
  int fps = 6;
  List<DrawnLine> get currentLines =>
      frames[currentFrameIndex.value].layers[currentLayerIndex.value].lines;
  set currentLines(List<DrawnLine> newLines) =>
      frames[currentFrameIndex.value].layers[currentLayerIndex.value].lines =
          newLines;
  List<LayerModel> get layers => frames[currentFrameIndex.value].layers;
  void addLayer() {
    for (var frame in frames) {
      frame.layers.add(LayerModel(name: 'Lớp ${frame.layers.length + 1}'));
    }
    numberOfLayers.value++;
    _clearThumbnailCache();
    frames.refresh();
  }
  void reorderLayer(int oldIdx, int newIdx) {
    for (var frame in frames) {
      if (oldIdx < frame.layers.length && newIdx < frame.layers.length) {
        final item = frame.layers.removeAt(oldIdx);
        frame.layers.insert(newIdx, item);
      }
    }
    _clearThumbnailCache();
    frames.refresh();
  }
  List<List<DrawnLine>>? copiedFrame;
  static const Size canvasSize = Size(1050, 590.625);
  final IconData brushIcon = MdiIcons.brushVariant;
  final IconData eraserIcon = MdiIcons.eraser;
  final IconData lineIcon = MdiIcons.vectorLine;
  final IconData rectangleIcon = MdiIcons.squareOutline;
  final IconData circleIcon = MdiIcons.circleOutline;
  final IconData bucketIcon = MdiIcons.formatColorFill;
  final IconData textIcon = MdiIcons.formatText;
  final String brushTooltip = 'Brush';
  final String eraserTooltip = 'Eraser';
  final String lineTooltip = 'Line';
  final String rectangleTooltip = 'Rectangle';
  final String circleTooltip = 'Circle';
  final String bucketTooltip = 'Fill';
  final String textTooltip = 'Text';
  final Rx<ToolType> selectedTool = ToolType.brush.obs;
  final selectedBlendModeIndex = 3.obs;
  IconData get currentToolIcon {
    switch (selectedTool.value) {
      case ToolType.brush:
        return brushIcon;
      case ToolType.eraser:
        return eraserIcon;
      case ToolType.line:
        return lineIcon;
      case ToolType.rectangle:
        return rectangleIcon;
      case ToolType.circle:
        return circleIcon;
      case ToolType.bucket:
        return bucketIcon;
      case ToolType.text:
        return textIcon;
    }
  }
  String get currentToolTooltip {
    switch (selectedTool.value) {
      case ToolType.brush:
        return brushTooltip;
      case ToolType.eraser:
        return eraserTooltip;
      case ToolType.line:
        return lineTooltip;
      case ToolType.rectangle:
        return rectangleTooltip;
      case ToolType.circle:
        return circleTooltip;
      case ToolType.bucket:
        return bucketTooltip;
      case ToolType.text:
        return textTooltip;
    }
  }
  void selectTool(ToolType type) => selectedTool.value = type;
  void selectBrush() => selectedTool.value = ToolType.brush;
  void selectEraser() => selectedTool.value = ToolType.eraser;
  bool get isEraserActive => selectedTool.value == ToolType.eraser;
  void setBrushPreset({
    required BrushType type,
    double scatter = 0.0,
    double hardness = 1.0,
    double? width,
  }) {
    selectedBrushType.value = type;
    selectedScatter.value = scatter;
    selectedHardness.value = hardness;
    if (width != null) selectedWidth.value = width;
    if (selectedTool.value != ToolType.brush) {
      selectedTool.value = ToolType.brush;
    }
  }
  void startStroke(Offset point) {
    if (selectedTool.value == ToolType.bucket) {
      _applyFloodFill(point);
      return;
    }
    if (selectedTool.value == ToolType.text) {
      _showTextInputDialog(point);
      return;
    }
    startPoint = point;
    undoStack.add(
      frames[currentFrameIndex.value].layers
          .map((layer) => layer.lines.map((line) => line.copy()).toList())
          .toList(),
    );
    redoStack.clear();
    final color =
        selectedTool.value == ToolType.eraser
            ? Colors.white
            : selectedColor.value;
    final int colorValue = color.toARGB32();
    final double opacity = selectedOpacity.value;
    final int blendModeIndex = selectedBlendModeIndex.value;
    if (selectedTool.value == ToolType.brush ||
        selectedTool.value == ToolType.eraser) {
      actualPoint.value = point;
      lazyPoint.value = point;
      currentTempLine.value = DrawnLine(
        points: [point],
        colorValue: colorValue,
        width: selectedWidth.value,
        brushType: selectedBrushType.value,
        scatter: selectedScatter.value,
        hardness: selectedHardness.value,
        opacity: opacity,
        blendModeIndex: blendModeIndex,
        vfxType: selectedVFX.value,
        spacing: selectedSpacing.value,
        angle: selectedAngle.value,
      );
      Get.find<CollabController>().updateLocalCursor(point);
    } else {
      currentTempLine.value = DrawnLine(
        points: [point, point],
        colorValue: colorValue,
        width: selectedWidth.value,
        opacity: opacity,
        blendModeIndex: blendModeIndex,
        vfxType: selectedVFX.value,
        spacing: selectedSpacing.value,
        angle: selectedAngle.value,
      );
    }
  }
  final Map<int, RxInt> frameVersions = {};
  final currentTempLine = Rx<DrawnLine?>(null);
  void addPoint(Offset point) {
    if (currentTempLine.value != null) {
      actualPoint.value = point;
      Offset processedPoint = point;
      if (isStabilizerEnabled.value && lazyPoint.value != null) {
        final dist = (point - lazyPoint.value!).distance;
        if (dist > stabilizerLength.value) {
          final direction = (point - lazyPoint.value!) / dist;
          processedPoint = point - direction * stabilizerLength.value;
          lazyPoint.value = processedPoint;
        } else {
          Get.find<CollabController>().updateLocalCursor(point);
          return;
        }
      } else {
        lazyPoint.value = point;
      }
      if (isPerspectiveSnapping.value &&
          perspectiveType.value != PerspectiveType.none &&
          currentTempLine.value!.points.isNotEmpty) {
        processedPoint = snapToPerspectiveLine(processedPoint);
      }
      if (isIsometricSnapEnabled.value &&
          currentTempLine.value!.points.isNotEmpty) {
        processedPoint = snapToIsometricGrid(processedPoint);
      }
      if (selectedTool.value == ToolType.brush ||
          selectedTool.value == ToolType.eraser) {
        currentTempLine.value!.addPoint(processedPoint);
      } else {
        if (selectedTool.value == ToolType.line) {
          currentTempLine.value!.replacePoints([startPoint, processedPoint]);
        } else if (selectedTool.value == ToolType.rectangle) {
          currentTempLine.value!.replacePoints([
            startPoint,
            Offset(processedPoint.dx, startPoint.dy),
            processedPoint,
            Offset(startPoint.dx, processedPoint.dy),
            startPoint,
          ]);
        } else if (selectedTool.value == ToolType.circle) {
          final radius = (processedPoint - startPoint).distance;
          final List<Offset> circlePoints = [];
          for (int i = 0; i <= 36; i++) {
            final angle = i * 10 * math.pi / 180;
            circlePoints.add(
              Offset(
                startPoint.dx + radius * math.cos(angle),
                startPoint.dy + radius * math.sin(angle),
              ),
            );
          }
          currentTempLine.value!.replacePoints(circlePoints);
        }
      }
      currentTempLine.refresh();
      Get.find<CollabController>().updateLocalCursor(point);
    }
  }
  Offset snapToIsometricGrid(Offset point) {
    if (currentTempLine.value == null ||
        currentTempLine.value!.points.isEmpty) {
      return point;
    }
    final prev = currentTempLine.value!.points.last;
    final delta = point - prev;
    if (delta.distance < 1) return point;
    const axes = [
      Offset(1.0, 0.0),
      Offset(0.5, -0.8660254), 
      Offset(-0.5, -0.8660254), 
    ];
    double bestDot = double.negativeInfinity;
    Offset bestAxis = axes[0];
    for (final axis in axes) {
      final dot = (delta.dx * axis.dx + delta.dy * axis.dy).abs();
      if (dot > bestDot) {
        bestDot = dot;
        final d = delta.dx * axis.dx + delta.dy * axis.dy;
        bestAxis = d >= 0 ? axis : Offset(-axis.dx, -axis.dy);
      }
    }
    final STUDIOjLength = delta.dx * bestAxis.dx + delta.dy * bestAxis.dy;
    return Offset(
      prev.dx + bestAxis.dx * STUDIOjLength,
      prev.dy + bestAxis.dy * STUDIOjLength,
    );
  }
  Offset snapToPerspectiveLine(Offset point) {
    if (currentTempLine.value == null ||
        currentTempLine.value!.points.isEmpty) {
      return point;
    }
    final prev = currentTempLine.value!.points.first; 
    if ((point - prev).distance < 1) return point;
    final List<Offset> activeVPs = [];
    switch (perspectiveType.value) {
      case PerspectiveType.onePoint:
        activeVPs.add(vanishingPoints[0]);
        break;
      case PerspectiveType.twoPoint:
        activeVPs.addAll([vanishingPoints[0], vanishingPoints[1]]);
        break;
      case PerspectiveType.threePoint:
        activeVPs.addAll(vanishingPoints);
        break;
      case PerspectiveType.none:
        return point;
    }
    Offset bestSnap = point;
    double bestDist = double.infinity;
    for (final vp in activeVPs) {
      Offset dir = prev - vp;
      final len = dir.distance;
      if (len < 1) continue;
      dir = dir / len;
      final t = (point.dx - vp.dx) * dir.dx + (point.dy - vp.dy) * dir.dy;
      final projected = Offset(vp.dx + dir.dx * t, vp.dy + dir.dy * t);
      final dist = (projected - point).distance;
      if (dist < bestDist) {
        bestDist = dist;
        bestSnap = projected;
      }
    }
    return bestSnap;
  }
  void startVpDrag(int index) {
    draggingVpIndex.value = index;
  }
  void updateVpDrag(Offset position) {
    final idx = draggingVpIndex.value;
    if (idx < 0 || idx >= vanishingPoints.length) return;
    vanishingPoints[idx] = position;
    vanishingPoints.refresh();
  }
  void endVpDrag() {
    draggingVpIndex.value = -1;
  }
  bool isNearVanishingPoint(Offset position, {double threshold = 20}) {
    if (perspectiveType.value == PerspectiveType.none) return false;
    for (final vp in vanishingPoints) {
      if ((vp - position).distance <= threshold) return true;
    }
    return false;
  }
  int? vpIndexAtPosition(Offset position, {double threshold = 20}) {
    if (perspectiveType.value == PerspectiveType.none) return null;
    for (int i = 0; i < vanishingPoints.length; i++) {
      if ((vanishingPoints[i] - position).distance <= threshold) return i;
    }
    return null;
  }
  void endStroke() {
    if (currentTempLine.value != null) {
      if (currentTempLine.value!.points.isNotEmpty) {
        redoStack.clear();
        final finishedLine = currentTempLine.value!;
        if (isSmoothingEnabled.value && finishedLine.points.length > 3 && selectedTool.value == ToolType.brush) {
          finishedLine.replacePoints(_smoothPoints(finishedLine.points));
          finishedLine.isSmoothed = true;
        }
        currentLines.add(finishedLine);
        Get.find<CollabController>().uploadStroke(finishedLine);
        if (symmetryType.value != SymmetryType.none) {
          _handleSymmetry(finishedLine);
        }
      }
      currentTempLine.value = null;
      lazyPoint.value = null;
      actualPoint.value = null;
      _clearThumbnailCache(frameIndex: currentFrameIndex.value);
      _clearThumbnailCache(
        frameIndex: currentFrameIndex.value,
        layerIndex: currentLayerIndex.value,
      );
      _invalidateLayerCache(currentLayerIndex.value);
      updateBackgroundPicture();
      frames.refresh();
      saveCurrentFrame();
      isChanged.value = true;
    }
  }
  void _handleSymmetry(DrawnLine finishedLine) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    if (symmetryType.value == SymmetryType.vertical || symmetryType.value == SymmetryType.both) {
      final mirrored = _mirrorLine(finishedLine, center.dx, true);
      currentLines.add(mirrored);
    }
    if (symmetryType.value == SymmetryType.horizontal || symmetryType.value == SymmetryType.both) {
      final mirrored = _mirrorLine(finishedLine, center.dy, false);
      currentLines.add(mirrored);
    }
    if (symmetryType.value == SymmetryType.both) {
      final mirroredV = _mirrorLine(finishedLine, center.dx, true);
      final mirroredBoth = _mirrorLine(mirroredV, center.dy, false);
      currentLines.add(mirroredBoth);
    }
    if (symmetryType.value == SymmetryType.radial4 || symmetryType.value == SymmetryType.radial8) {
      final int count = symmetryType.value == SymmetryType.radial4 ? 4 : 8;
      for (int i = 1; i < count; i++) {
        final angle = (2 * math.pi / count) * i;
        currentLines.add(_rotateLine(finishedLine, center, angle));
      }
    }
  }
  DrawnLine _rotateLine(DrawnLine line, Offset center, double angle) {
    final rotatedPoints = line.points.map((p) {
      final dx = p.dx - center.dx;
      final dy = p.dy - center.dy;
      return Offset(
        center.dx + dx * math.cos(angle) - dy * math.sin(angle),
        center.dy + dx * math.sin(angle) + dy * math.cos(angle),
      );
    }).toList();
    return line.copy()..replacePoints(rotatedPoints);
  }
  List<Offset> _smoothPoints(List<Offset> points) {
    if (points.length < 3) return points;
    final List<Offset> smoothed = [];
    smoothed.add(points.first);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      for (double t = 0.2; t <= 1.0; t += 0.2) {
        smoothed.add(_calculateCatmullRomPoint(p0, p1, p2, p3, t));
      }
    }
    return smoothed;
  }
  Offset _calculateCatmullRomPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;
    return Offset(
      0.5 * ( (2 * p1.dx) + (p2.dx - p0.dx) * t + (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 + (3 * p1.dx - p0.dx - 3 * p2.dx + p3.dx) * t3 ),
      0.5 * ( (2 * p1.dy) + (p2.dy - p0.dy) * t + (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 + (3 * p1.dy - p0.dy - 3 * p2.dy + p3.dy) * t3 )
    );
  }
  DrawnLine _mirrorLine(DrawnLine line, double axisValue, bool isVerticalAxis) {
    _invalidateLayerCache(currentLayerIndex.value);
    final mirroredPoints =
        line.points.map((p) {
          if (isVerticalAxis) {
            return Offset(axisValue * 2 - p.dx, p.dy);
          } else {
            return Offset(p.dx, axisValue * 2 - p.dy);
          }
        }).toList();
    return DrawnLine(
      points: mirroredPoints,
      colorValue: line.colorValue,
      width: line.width,
      brushType: line.brushType,
      scatter: line.scatter,
      hardness: line.hardness,
      opacity: line.opacity,
      blendModeIndex: line.blendModeIndex,
      text: line.text,
      isFill: line.isFill,
    );
  }
  Future<void> _applyFloodFill(Offset point) async {
    final fillLine = DrawnLine(
      points: [point],
      colorValue: selectedColor.value.toARGB32(),
      width: 1.0,
      opacity: selectedOpacity.value,
      isFill: true,
    );
    currentLines.add(fillLine);
    frames.refresh();
    isChanged.value = true;
    saveCurrentFrame();
  }
  void _showTextInputDialog(Offset point) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Add Text"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter text here..."),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final textLine = DrawnLine(
                  points: [point],
                  colorValue: selectedColor.value.toARGB32(),
                  width: selectedWidth.value,
                  opacity: selectedOpacity.value,
                  text: textController.text,
                );
                currentLines.add(textLine);
                frames.refresh();
                isChanged.value = true;
                saveCurrentFrame();
              }
              Get.back();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
  void updateBackgroundPicture() {
    final frameIndex = currentFrameIndex.value;
    final frame = frames[frameIndex];
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
    );
    canvas.drawColor(canvasBackgroundColor.value, BlendMode.src);
    if (showGrid.value) {
      _drawGrid(canvas, canvasSize);
    }
    for (int i = 0; i < frame.layers.length; i++) {
        final layer = frame.layers[i];
        if (!layer.isVisible) continue;
        if (!_layerCache.containsKey(i)) {
           final layerRecorder = ui.PictureRecorder();
           final layerCanvas = Canvas(layerRecorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
           SketcherFull(
             mainLines: layer.lines,
             opacity: 1.0, 
           ).paint(layerCanvas, canvasSize);
           _layerCache[i] = layerRecorder.endRecording();
        }
        final paint = Paint()
          ..color = Colors.white.withValues(alpha: layer.opacity)
          ..blendMode = BlendMode.values[layer.blendModeIndex];
        canvas.drawPicture(_layerCache[i]!);
    }
    currentBackgroundPicture.value = recorder.endRecording();
    currentBackgroundPicture.refresh();
  }
  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    final double step = gridSize.value;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  void updateLayerOpacity(int index, double opacity) {
    if (index < 0 || index >= frames[currentFrameIndex.value].layers.length) {
      return;
    }
    frames[currentFrameIndex.value].layers[index].opacity = opacity.clamp(
      0.0,
      1.0,
    );
    _clearThumbnailCache(
      frameIndex: currentFrameIndex.value,
      layerIndex: index,
    );
    updateBackgroundPicture();
    frames.refresh();
  }
  void updateLayerBlendMode(int index, int blendModeIndex) {
    if (index < 0 || index >= frames[currentFrameIndex.value].layers.length) {
      return;
    }
    frames[currentFrameIndex.value].layers[index].blendModeIndex =
        blendModeIndex;
    _clearThumbnailCache(
      frameIndex: currentFrameIndex.value,
      layerIndex: index,
    );
    updateBackgroundPicture();
    frames.refresh();
  }
  void toggleLayerVisibility(int index) {
    if (index < 0 || index >= frames[currentFrameIndex.value].layers.length) {
      return;
    }
    final layer = frames[currentFrameIndex.value].layers[index];
    layer.isVisible = !layer.isVisible;
    updateBackgroundPicture();
    frames.refresh();
  }
  void renameLayer(int index, String newName) {
    if (index < 0 || index >= frames[currentFrameIndex.value].layers.length) {
      return;
    }
    frames[currentFrameIndex.value].layers[index].name = newName;
    frames.refresh();
  }
  void duplicateFrame(int index) {
    if (index < 0 || index >= frames.length) return;
    final originalFrame = frames[index];
    final clonedFrame = originalFrame.copy();
    frames.insert(index + 1, clonedFrame);
    selectFrame(index + 1);
    saveCurrentFrame();
    updateBackgroundPicture();
    isChanged.value = true;
    frames.refresh();
  }
  void toggleGrid() {
    showGrid.toggle();
    updateBackgroundPicture();
  }
  void changeBackgroundColor(Color color) {
    canvasBackgroundColor.value = color;
    updateBackgroundPicture();
  }
  void updateNumberOfLayers(int count) {
    if (count < 1 || count > 10) return;
    numberOfLayers.value = count;
    for (final frame in frames) {
      if (frame.layers.length < count) {
        while (frame.layers.length < count) {
          frame.layers.add(LayerModel());
        }
      } else if (frame.layers.length > count) {
        while (frame.layers.length > count) {
          frame.layers.removeLast();
        }
      }
    }
    if (currentLayerIndex.value >= count) {
      currentLayerIndex.value = count - 1;
    }
    updateBackgroundPicture();
    frames.refresh();
  }
  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(
        frames[currentFrameIndex.value].layers
            .map((layer) => layer.lines.map((line) => line.copy()).toList())
            .toList(),
      );
      final previous = undoStack.removeLast();
      for (int i = 0; i < frames[currentFrameIndex.value].layers.length; i++) {
        frames[currentFrameIndex.value].layers[i].lines = previous[i];
      }
      _layerCache.clear();
      updateBackgroundPicture();
      frames.refresh();
      saveCurrentFrame();
    }
  }
  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(
        frames[currentFrameIndex.value].layers
            .map((layer) => layer.lines.map((line) => line.copy()).toList())
            .toList(),
      );
      final next = redoStack.removeLast();
      for (int i = 0; i < frames[currentFrameIndex.value].layers.length; i++) {
        frames[currentFrameIndex.value].layers[i].lines = next[i];
      }
      _layerCache.clear();
      updateBackgroundPicture();
      frames.refresh();
      saveCurrentFrame();
    }
  }
  void removeThumbnailCacheForFrame(int frameIndex) {
    final keysToRemove =
        thumbnailCache.keys
            .where((key) => key.startsWith('$frameIndex'))
            .toList();
    for (final key in keysToRemove) {
      thumbnailCache.remove(key);
    }
  }
  void clearCanvas() {
    undoStack.add(
      frames[currentFrameIndex.value].layers
          .map((layer) => layer.lines.map((line) => line.copy()).toList())
          .toList(),
    );
    for (int i = 0; i < frames[currentFrameIndex.value].layers.length; i++) {
      frames[currentFrameIndex.value].layers[i].lines.clear();
    }
    _layerCache.clear();
    updateBackgroundPicture();
    frames.refresh();
    saveCurrentFrame();
  }
  void toggleEraser() => selectTool(
    selectedTool.value == ToolType.eraser ? ToolType.brush : ToolType.eraser,
  );
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) =>
      selectedWidth.value = width.clamp(1.0, 30.0);
  void changeOpacity(double opacity) =>
      selectedOpacity.value = opacity.clamp(0.0, 1.0);
  void toggleFrameList() => isFrameListExpanded.toggle();
  void addFrame() {
    final newFrame = FrameModel(
      numberOfLayers: numberOfLayers.value,
    );
    frames.insert(0, newFrame);
    currentFrameIndex.value = 0;
    currentLayerIndex.value = 0;
    isChanged.value = true;
    _clearThumbnailCache();
  }
  void resetLayerIndex() {
    if (currentLayerIndex.value == 0) {
      currentLayerIndex.value = -1;
    }
    currentLayerIndex.value = 0;
  }
  void selectFrame(int index) {
    if (index == currentFrameIndex.value) return;
    currentFrameIndex.value = index;
    final context = frameItemKeys[index]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, alignment: 0.5);
    }
    _layerCache.clear();
    updateBackgroundPicture();
  }
  void switchLayer(int layerIndex) {
    currentLayerIndex.value = layerIndex;
    updateBackgroundPicture();
  }
  Timer? _thumbnailDebounceTimer;
  void saveCurrentFrame() {
    _thumbnailDebounceTimer?.cancel();
    _thumbnailDebounceTimer = Timer(
      const Duration(milliseconds: 200),
      () async {
        await renderThumbnail(currentFrameIndex.value, null, true);
        await renderThumbnail(
          currentFrameIndex.value,
          currentLayerIndex.value,
          true,
        );
      },
    );
  }
  void copyFrame(int index) {
    if (index >= 0 && index < frames.length) {
      copiedFrame =
          frames[index].layers
              .map((layer) => layer.lines.map((line) => line.copy()).toList())
              .toList();
    }
  }
  void copyFrameCurrent() {
    final index = currentFrameIndex.value;
    copyFrame(index);
  }
  void pasteCopiedFrame() {
    if (copiedFrame == null) return;
    final newFrame = FrameModel(numberOfLayers: copiedFrame!.length);
    for (int i = 0; i < newFrame.layers.length; i++) {
      newFrame.layers[i].lines =
          copiedFrame![i].map((line) => line.copy()).toList();
    }
    final insertIndex = currentFrameIndex.value + 1;
    frames.insert(insertIndex, newFrame);
    selectFrame(insertIndex);
    isChanged.value = true;
  }
  Future<void> save() async {
    if (currentProjectId != null && currentProjectName != null) {
      await saveProjectToHive(currentProjectId!, currentProjectName!);
      isChanged.value = false;
      Get.snackbar(
        "Success",
        "project saved successfully.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar("Error", "No project selected to save.");
    }
  }
  Future<void> leaveSaving() async {
    if (isChanged.value) {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: const Text('Save changes?'),
            content: const Text(
              'Do you want to save the changes before leaving?',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await safeBack();
                  if (currentProjectId != null && currentProjectName != null) {
                    await saveProjectToHive(
                      currentProjectId!,
                      currentProjectName!,
                    );
                  }
                  await safeBack();
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () async {
                  await safeBack();
                  await safeBack();
                },
                child: const Text('Don\'t save'),
              ),
            ],
          );
        },
      );
    } else {
      await safeBack();
    }
  }
  void reorderFrame(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = frames.removeAt(oldIndex);
    frames.insert(newIndex, item);
    _clearThumbnailCache();
    frames.refresh();
    if (currentFrameIndex.value == oldIndex) {
      currentFrameIndex.value = newIndex;
    } else if (currentFrameIndex.value == newIndex) {
      currentFrameIndex.value = oldIndex;
    } else if (oldIndex < currentFrameIndex.value &&
        currentFrameIndex.value <= newIndex) {
      currentFrameIndex.value -= 1;
    } else if (newIndex <= currentFrameIndex.value &&
        currentFrameIndex.value < oldIndex) {
      currentFrameIndex.value += 1;
    }
  }
  RxSet<int> hiddenFrames = <int>{}.obs;
  bool isFrameHidden(int index) => hiddenFrames.contains(index);
  bool isLayerHidden(int index) {
    final frame = frames[currentFrameIndex.value];
    if (index < 0 || index >= frame.layers.length) return false;
    return !frame.layers[index].isVisible;
  }
  void toggleFrameVisibility(int index) {
    if (hiddenFrames.contains(index)) {
      hiddenFrames.remove(index);
    } else {
      hiddenFrames.add(index);
    }
  }
  void removeFrame(int index) {
    frames.removeAt(index);
    frames[currentFrameIndex.value] = frames[currentFrameIndex.value].copy();
    _clearThumbnailCache();
    isChanged.value = true;
  }
  Future<void> deleteCurrentFrame() async {
    if (frames.length <= 1) return;
    final index = currentFrameIndex.value;
    removeFrame(index);
    if (index >= frames.length) {
      currentFrameIndex.value = frames.length - 1;
    }
    await renderThumbnail(currentFrameIndex.value);
  }
  void togglePlayback() {
    isPlaying.toggle();
    _playbackTimer?.cancel();
    if (isPlaying.value) {
      _currentIndex = frames.length - 1;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frames.isEmpty) return;
        selectFrame(_currentIndex);
        _currentIndex = (_currentIndex - 1) % frames.length;
        if (_currentIndex < 0) {
          _currentIndex = frames.length - 1;
        }
      });
    }
  }
  void setFps(int value) {
    fps = value;
    playbackSpeed.value = value;
    if (isPlaying.value) {
      togglePlayback();
      togglePlayback();
    }
  }
  Future<Uint8List?> captureImageSmooth() async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 50),
      );
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
    }
    return null;
  }
  Future<Uint8List> renderThumbnail(
    int frameIndex, [
    int? layerIndex,
    bool forceUpdate = false,
  ]) async {
    if (frameIndex < 0 || frameIndex >= frames.length) {
      throw ArgumentError('Invalid frameIndex: $frameIndex');
    }
    final cacheKey =
        layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
    if (!forceUpdate && thumbnailCache.containsKey(cacheKey)) {
      return thumbnailCache[cacheKey]!;
    }
    const double thumbWidth = 1050;
    const double thumbHeight = 590.625;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, thumbWidth, thumbHeight),
    );
    final scaleX = thumbWidth / canvasSize.width;
    final scaleY = thumbHeight / canvasSize.height;
    canvas.scale(scaleX, scaleY);
    canvas.drawColor(Colors.white, BlendMode.src);
    try {
      if (layerIndex == null) {
        for (int i = 0; i < frames[frameIndex].layers.length; i++) {
          final layer = frames[frameIndex].layers[i];
          if (layer.isVisible) {
            SketcherFull(
              mainLines: layer.lines,
              opacity: layer.opacity,
              onionSkinLines: null,
            ).paint(canvas, canvasSize);
          }
        }
      } else {
        final layer = frames[frameIndex].layers[layerIndex];
        SketcherFull(
          mainLines: layer.lines,
          opacity: layer.opacity,
          onionSkinLines: null,
        ).paint(canvas, canvasSize);
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        thumbWidth.toInt(),
        thumbHeight.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to encode image to byteData");
      }
      final bytes = byteData.buffer.asUint8List();
      thumbnailCache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      return Uint8List(0);
    }
  }
  Future<void> exportFrameAsImage(int frameIndex) async {
    if (frameIndex < 0 || frameIndex >= frames.length) {
      Get.snackbar("Error", "Frame index invalid.");
      return;
    }
    final bool granted = await ensureStoragePermission();
    if (!granted) {
      Get.snackbar("Error", "Storage permission not granted.");
      return;
    }
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) {
      Get.snackbar("Cancelled", "You not choose folder yet.");
      return;
    }
    final bytes = await renderThumbnail(frameIndex);
    final filePath = "$dir/frame_${frameIndex.toString().padLeft(3, '0')}.png";
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    Get.snackbar(
      "Export Successful",
      "The exported image has been saved as PNG.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  bool isInsideCanvas(Offset point) {
    final box = repaintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final size = box.size;
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= size.width &&
        point.dy <= size.height;
  }
  Future<void> renderAllFramesToImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory("${dir.path}/frames");
    if (!outputDir.existsSync()) {
      await outputDir.create(recursive: true);
    }
    for (int i = 0; i < frames.length; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      );
      canvas.drawColor(Colors.white, BlendMode.src);
      for (int l = 0; l < frames[i].layers.length; l++) {
        final layer = frames[i].layers[l];
        if (layer.isVisible) {
          SketcherFull(
            mainLines: layer.lines,
            opacity: layer.opacity,
          ).paint(canvas, canvasSize);
        }
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final filePath =
          "${outputDir.path}/frame_${i.toString().padLeft(3, '0')}.png";
      await File(filePath).writeAsBytes(bytes);
    }
  }
  Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
  }
  Future<void> exportToGif() async {
    final String? projectName = await _getprojectNameFromUser();
    if (projectName == null || projectName.isEmpty) return;
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "export_frames"));
    if (framesDir.existsSync()) await framesDir.delete(recursive: true);
    await framesDir.create(recursive: true);
    final fps = playbackSpeed.value;
    for (int i = 0; i < frames.length; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      );
      canvas.drawColor(canvasBackgroundColor.value, BlendMode.src);
      for (final layer in frames[i].layers) {
        if (layer.isVisible) {
          SketcherFull(
            mainLines: layer.lines,
            opacity: layer.opacity,
            symmetryType: SymmetryType.none,
          ).paint(canvas, canvasSize);
        }
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final filePath = p.join(
        framesDir.path,
        'frame_${i.toString().padLeft(3, '0')}.png',
      );
      await File(filePath).writeAsBytes(bytes);
    }
    final outputPath = p.join(selectedDirectory, '$projectName.gif');
    final cmd =
        "-y -framerate $fps -i ${framesDir.path}/frame_%03d.png "
        "-vf \"scale=trunc(iw/2)*2:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" "
        "$outputPath";
    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      Get.snackbar(
        "Success",
        "GIF exported successfully:\n$outputPath",
        snackPosition: SnackPosition.BOTTOM,
      );
      await framesDir.delete(recursive: true);
    } else {
      Get.snackbar(
        "Error",
        "GIF export failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> exportToMp4() async {
    final String? projectName = await _getprojectNameFromUser();
    if (projectName == null || projectName.isEmpty) return;
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "export_frames"));
    if (framesDir.existsSync()) await framesDir.delete(recursive: true);
    await framesDir.create(recursive: true);
    final fps = playbackSpeed.value;
    for (int i = 0; i < frames.length; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      );
      canvas.drawColor(canvasBackgroundColor.value, BlendMode.src);
      for (final layer in frames[i].layers) {
        if (layer.isVisible) {
          SketcherFull(
            mainLines: layer.lines,
            opacity: layer.opacity,
            symmetryType: SymmetryType.none,
          ).paint(canvas, canvasSize);
        }
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final filePath = p.join(
        framesDir.path,
        'frame_${i.toString().padLeft(3, '0')}.png',
      );
      await File(filePath).writeAsBytes(bytes);
    }
    final outputPath = p.join(selectedDirectory, '$projectName.mp4');
    final cmd =
        "-y -framerate $fps -i ${framesDir.path}/frame_%03d.png "
        "-vf \"scale=trunc(iw/2)*2:trunc(ih/2)*2\" "
        "-c:v libx264 -pix_fmt yuv420p $outputPath";
    final session = await FFmpegKit.execute(cmd);
    if (ReturnCode.isSuccess(await session.getReturnCode())) {
      Get.snackbar(
        "Success",
        "Video exported successfully:\n$outputPath",
        snackPosition: SnackPosition.BOTTOM,
      );
      await framesDir.delete(recursive: true);
    } else {
      Get.snackbar(
        "Error",
        "Export failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> uploadImageToprofile(
    String userId, {
    int? selectedFrameIndex,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final frameIndex = selectedFrameIndex ?? currentFrameIndex.value;
    final thumbPath = p.join(tempDir.path, 'upload_image.png');
    final imageFile = await renderThumbnailToFile(frameIndex, thumbPath);
    if (imageFile == null) {
      Get.snackbar("Error", "Failed to render image for upload.");
      return;
    }
    final uploadController = Get.find<UploadController>();
    uploadController.nameController.text = currentProjectName ?? 'New Artwork';
    uploadController.descriptionController.text =
        'Created using Calliope drawing app';
    uploadController.allowRemix.value = true;
    uploadController.currentProjectToUpload = DrawProjectModel(
      id: currentProjectId ?? "remix_${DateTime.now().millisecondsSinceEpoch}",
      name: currentProjectName ?? uploadController.nameController.text,
      updatedAt: DateTime.now(),
      frames: frames.map((f) => f.copy()).toList(),
    );
    final confirmed = await _showPostCustomizationDialog(uploadController);
    if (!confirmed) return;
    await uploadController.uploadImage(userId, imageFile);
  }
  Future<void> showCommunityShareDialog() async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null || !profileController.isLogined.value) {
      Get.snackbar(
        "Login Required",
        "Please login to share your artwork with the community.",
      );
      return;
    }
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share to Community",
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How would you like to share your masterpiece?",
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _shareOptionCard(
                      icon: Icons.image_outlined,
                      title: "Image",
                      description:
                          "Share a single frame as a high-quality image.",
                      onTap: () async {
                        await safeBack();
                        _showFrameSelectionDialog(userId, isVideo: false);
                      },
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _shareOptionCard(
                      icon: Icons.movie_outlined,
                      title: "Video",
                      description: "Share your entire animation as a video.",
                      onTap: () async {
                        await safeBack();
                        showUploadDialogWithInfo(playbackSpeed.value, userId);
                      },
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _shareOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showFrameSelectionDialog(
    String userId, {
    required bool isVideo,
  }) async {
    int selectedIndex = currentFrameIndex.value;
    await Get.dialog(
      StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
              title: const Text("Select Frame"),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Choose the frame you want to share:"),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      width: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: frames.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      selectedIndex == index
                                          ? Colors.blue
                                          : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: FutureBuilder<Uint8List>(
                                  future: renderThumbnail(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async => await safeBack(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uploadController = Get.find<UploadController>();
                    if (uploadController.isUploading.value) return;
                    await safeBack();
                    if (isVideo) {
                    } else {
                      final bytes = await renderThumbnail(selectedIndex);
                      final tempDir = await getTemporaryDirectory();
                      final file = await File(
                        p.join(tempDir.path, 'upload_image.png'),
                      ).writeAsBytes(bytes);
                      uploadController.nameController.text =
                          currentProjectName ?? 'New Artwork';
                      uploadController.descriptionController.text =
                          'Created using Calliope drawing app';
                      uploadController.allowRemix.value = true;
                      uploadController.currentProjectToUpload = DrawProjectModel(
                        id:
                            currentProjectId ??
                            "remix_${DateTime.now().millisecondsSinceEpoch}",
                        name:
                            currentProjectName ??
                            uploadController.nameController.text,
                        updatedAt: DateTime.now(),
                        frames: frames.map((f) => f.copy()).toList(),
                      );
                      final confirmed = await _showPostCustomizationDialog(
                        uploadController,
                      );
                      if (!confirmed) return;
                      uploadController.uploadImage(userId, file);
                    }
                  },
                  child: const Text("Select"),
                ),
              ],
            ),
      ),
    );
  }
  Future<void> uploadVideoToprofile(
    int fps,
    String userId, {
    int? selectedFrameIndex,
    String? customName,
    String? customDescription,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "upload_frames"));
    if (!framesDir.existsSync()) {
      await framesDir.create(recursive: true);
    }
    for (int i = frames.length - 1; i >= 0; i--) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      );
      canvas.drawColor(Colors.white, BlendMode.src);
      for (int l = 0; l < frames[i].layers.length; l++) {
        final layer = frames[i].layers[l];
        if (layer.isVisible) {
          SketcherFull(
            mainLines: layer.lines,
            opacity: layer.opacity,
            onionSkinLines: null,
          ).paint(canvas, canvasSize);
        }
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final framePath = p.join(
        framesDir.path,
        'frame_${(frames.length - 1 - i).toString().padLeft(3, '0')}.png',
      );
      await File(framePath).writeAsBytes(bytes);
    }
    final outputVideoPath = p.join(tempDir.path, 'upload_video.mp4');
    final ffmpegCommand =
        "-y -framerate $fps -start_number 0 -i ${framesDir.path}/frame_%03d.png "
        "-vf scale='trunc(iw/2)*2:trunc(ih/2)*2' "
        "-c:v libx264 -pix_fmt yuv420p $outputVideoPath";
    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      safeSnackbar("Error", "Failed to generate video for upload.");
      return;
    }
    final uploadController = Get.find<UploadController>();
    uploadController.videoFile.value = File(outputVideoPath);
    final frameIndex = selectedFrameIndex ?? 0;
    final thumbPath = p.join(tempDir.path, 'thumbnail.png');
    final thumb = await renderThumbnailToFile(frameIndex, thumbPath);
    if (thumb != null) {
      uploadController.backgroundFile.value = thumb;
    }
    uploadController.nameController.text =
        customName ?? currentProjectName ?? 'New Video';
    uploadController.descriptionController.text =
        customDescription ?? 'Created using Calliope drawing app';
    uploadController.allowRemix.value = true;
    uploadController.currentProjectToUpload = DrawProjectModel(
      id: currentProjectId ?? "remix_${DateTime.now().millisecondsSinceEpoch}",
      name: currentProjectName ?? uploadController.nameController.text,
      updatedAt: DateTime.now(),
      frames: frames.map((f) => f.copy()).toList(),
    );
    final confirmed = await _showPostCustomizationDialog(uploadController);
    if (!confirmed) {
      safeSnackbar("Cancelled", "Upload cancelled by user.");
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await uploadController.uploadVideo(userId);
    if (framesDir.existsSync()) {
      try {
        await framesDir.delete(recursive: true);
        final videoFile = File(outputVideoPath);
        if (videoFile.existsSync()) {
          await videoFile.delete();
        }
      } catch (e) {
      }
    }
  }
  Future<void> generateTween(int fromIndex, int toIndex, int steps) async {
    if (fromIndex < 0 ||
        toIndex >= frames.length ||
        fromIndex >= toIndex ||
        steps < 1) {
      safeSnackbar("Error", "Invalid parameter");
      return;
    }
    final layerIndex = currentLayerIndex.value;
    final fromLines = frames[fromIndex].layers[layerIndex].lines;
    final toLines = frames[toIndex].layers[layerIndex].lines;
    final maxLines =
        fromLines.length > toLines.length ? fromLines.length : toLines.length;
    final generatedFrames = <FrameModel>[];
    for (int s = 1; s <= steps; s++) {
      final t = s / (steps + 1);
      final tweenLines = <DrawnLine>[];
      for (int i = 0; i < maxLines; i++) {
        final a =
            i < fromLines.length
                ? fromLines[i]
                : DrawnLine(
                  points: [],
                  colorValue: Colors.black.toARGB32(),
                  width: 1,
                );
        final b =
            i < toLines.length
                ? toLines[i]
                : DrawnLine(
                  points: [],
                  colorValue: Colors.black.toARGB32(),
                  width: 1,
                );
        final minLen =
            a.points.length < b.points.length
                ? a.points.length
                : b.points.length;
        final points = <Offset>[];
        for (int j = 0; j < minLen; j++) {
          final p = Offset.lerp(a.points[j], b.points[j], t);
          points.add(p ?? a.points[j]);
        }
        if (a.points.length > b.points.length) {
          points.addAll(a.points.sublist(minLen));
        } else if (b.points.length > a.points.length) {
          points.addAll(b.points.sublist(minLen));
        }
        tweenLines.add(
          DrawnLine(
            points: points,
            colorValue:
                Color.lerp(
                  Color(a.colorValue),
                  Color(b.colorValue),
                  t,
                )?.toARGB32() ??
                a.colorValue,
            width: a.width + (b.width - a.width) * t,
          ),
        );
      }
      final tweenFrame = FrameModel();
      tweenFrame.layers[layerIndex].lines = tweenLines;
      generatedFrames.add(tweenFrame);
    }
    frames.insertAll(fromIndex + 1, generatedFrames);
    _clearThumbnailCache();
    frames.refresh();
    safeSnackbar(
      "Tween succeed",
      "Inserted $steps as child frame of $fromIndex and $toIndex",
    );
  }
  Future<File?> renderThumbnailToFile(int frameIndex, String path) async {
    try {
      final bytes = await renderThumbnail(frameIndex);
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }
  Future<void> showUploadDialogWithInfo(int fps, String userId) async {
    final nameController = TextEditingController();
    int? selectedFrameIndex;
    await Get.dialog(
      AlertDialog(
        title: const Text("Upload Video"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Video Name"),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Select a frame to use as thumbnail (or skip to choose an image from device):",
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  width: double.maxFinite,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: frames.length,
                    itemBuilder: (_, index) {
                      return FutureBuilder<Uint8List>(
                        future: renderThumbnail(index),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
                              !snapshot.hasData) {
                            return const SizedBox(
                              width: 80,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return GestureDetector(
                            onTap: () => selectedFrameIndex = index,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      selectedFrameIndex == index
                                          ? Colors.blue
                                          : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Image.memory(snapshot.data!, width: 80),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      safeSnackbar(
                        "Image selected",
                        "The chosen image will be used as the thumbnail",
                      );
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Choose image from device"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async => await safeBack(),
            child: const Text("Cancel"),
          ),
          Obx(() {
            final uploadController = Get.find<UploadController>();
            final bool uploading = uploadController.isUploading.value;
            return ElevatedButton(
              onPressed:
                  uploading
                      ? null
                      : () async {
                        await safeBack();
                        await uploadVideoToprofile(
                          fps,
                          userId,
                          selectedFrameIndex: selectedFrameIndex,
                          customName: nameController.text,
                        );
                      },
              child:
                  uploading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text("Upload video"),
            );
          }),
        ],
      ),
    );
  }
  Future<List<Uint8List>> getAllFrameThumbnails() async {
    final List<Uint8List> framesData = [];
    for (int i = frames.length - 1; i >= 0; i--) {
      final bytes = await renderThumbnail(i);
      framesData.add(bytes);
    }
    return framesData;
  }
  void _clearThumbnailCache({int? frameIndex, int? layerIndex}) {
    if (frameIndex == null) {
      thumbnailCache.clear();
    } else {
      final key =
          layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
      thumbnailCache.remove(key);
    }
  }
  void scrollToTop() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  Future<void> safeBack({dynamic result}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      if (Get.context != null) {
        Navigator.of(Get.context!).pop(result);
      } else {
        Get.back(result: result);
      }
    } catch (e) {
      try {
        Get.back(result: result);
      } catch (_) {}
    }
  }
  void safeSnackbar(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                '$title: $message',
                style: const TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
      }
    });
  }
}
Future<String?> _getprojectNameFromUser() async {
  final TextEditingController controller = TextEditingController();
  return await Get.dialog<String>(
    AlertDialog(
      title: const Text("Enter project Name"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "e.g., my_animation"),
      ),
      actions: [
        TextButton(
          onPressed:
              () async =>
                  await Get.find<DrawController>().safeBack(result: null),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed:
              () async => await Get.find<DrawController>().safeBack(
                result: controller.text.trim(),
              ),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
Future<bool> _showPostCustomizationDialog(UploadController controller) async {
  return await Get.dialog<bool>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Customize Your Post",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: "Video Title",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: controller.descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      final uploadController = Get.find<UploadController>();
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.deepPurple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: CheckboxListTile(
                          value: uploadController.allowRemix.value,
                          onChanged:
                              (val) =>
                                  uploadController.allowRemix.value =
                                      val ?? true,
                          title: const Text(
                            "Allow Remixing",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Attaches your project file so others can color or draw over your template.",
                            style: TextStyle(fontSize: 12),
                          ),
                          activeColor: const Color(0xFF8C52FF),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              () async => await Get.find<DrawController>()
                                  .safeBack(result: false),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        Obx(() {
                          final uploadController = Get.find<UploadController>();
                          final bool uploading =
                              uploadController.isUploading.value;
                          return ElevatedButton.icon(
                            onPressed:
                                uploading
                                    ? null
                                    : () async =>
                                        await Get.find<DrawController>()
                                            .safeBack(result: true),
                            icon:
                                uploading
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Icons.upload),
                            label: Text(uploading ? "Uploading..." : "Upload"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ) ??
      false;
}
class OptimizedSketcher extends CustomPainter {
  final ui.Picture? backgroundPicture;
  final DrawnLine? currentLine;
  OptimizedSketcher({
    required this.backgroundPicture,
    required this.currentLine,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundPicture != null) {
      canvas.drawPicture(backgroundPicture!);
    }
    if (currentLine != null && currentLine!.points.length > 1) {
      final paint =
          Paint()
            ..color = Color(currentLine!.colorValue)
            ..strokeWidth = currentLine!.width
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
      final path =
          Path()..moveTo(currentLine!.points[0].dx, currentLine!.points[0].dy);
      for (int i = 1; i < currentLine!.points.length; i++) {
        path.lineTo(currentLine!.points[i].dx, currentLine!.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant OptimizedSketcher oldDelegate) {
    return backgroundPicture != oldDelegate.backgroundPicture ||
        currentLine != oldDelegate.currentLine;
  }
}
