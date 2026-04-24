import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/draw/drawn_line_model.dart';
import '../../profile/controllers/profile_controller.dart';
import 'draw_controller.dart';

class CollabController extends GetxController {
  late final DrawController drawController;
  final ProfileController profileController = Get.find<ProfileController>();
  
  RealtimeChannel? _roomChannel;

  @override
  void onInit() {
    super.onInit();
    drawController = Get.find<DrawController>();
  }

  final RxString activeRoomId = ''.obs;
  final RxBool isCollaborating = false.obs;
  final RxList<Map<String, dynamic>> activeMembers =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, Offset> remoteCursors = <String, Offset>{}.obs;
  final Map<String, Offset> _targetCursors = {}; 
  final RxMap<String, Color> memberColors = <String, Color>{}.obs;

  Timer? _presenceTimer;

  final List<Color> _availableColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
    Colors.amber,
  ];

  @override
  void onClose() {
    stopCollaboration();
    super.onClose();
  }

  Future<void> createRoom() async {
    final roomId = const Uuid().v4().substring(0, 8).toUpperCase();
    await _setupRoom(roomId);
  }

  Future<void> joinRoom(String roomId) async {
    await _setupRoom(roomId);
  }

  Future<void> _setupRoom(String roomId) async {
    stopCollaboration();
    activeRoomId.value = roomId;
    isCollaborating.value = true;

    final user = profileController.currentUser.value;
    if (user == null) return;

    _roomChannel = Supabase.instance.client.channel('room_$roomId');

    _roomChannel!
      .onBroadcast(event: 'stroke', callback: (payload) {
        _handleRemoteStroke(payload);
      })
      .onBroadcast(event: 'presence', callback: (payload) {
        _handlePresence(payload);
      })
      .subscribe();

    _presenceTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updatePresence();
    });
    
    
    _startCursorInterpolation();
    _updatePresence();
  }

  void stopCollaboration() {
    _roomChannel?.unsubscribe();
    _roomChannel = null;
    _presenceTimer?.cancel();
    isCollaborating.value = false;
    activeRoomId.value = '';
    remoteCursors.clear();
    activeMembers.clear();
  }

  void _handlePresence(Map<String, dynamic> data) {
    final user = profileController.currentUser.value;
    if (user == null) return;
    
    final userId = data['id'] as String?;
    if (userId == null || userId == user.id) return;
    
    final existingMemberIndex = activeMembers.indexWhere((m) => m['id'] == userId);
    final memberData = {
      'id': userId,
      'name': data['name'] ?? 'Artist',
      'lastSeen': DateTime.now()
    };
    
    if (existingMemberIndex >= 0) {
      activeMembers[existingMemberIndex] = memberData;
    } else {
      activeMembers.add(memberData);
      memberColors[userId] = _availableColors[memberColors.length % _availableColors.length];
    }
    
    
    _targetCursors[userId] = Offset((data['x'] as num).toDouble(), (data['y'] as num).toDouble());
    
    if (!remoteCursors.containsKey(userId)) {
      remoteCursors[userId] = _targetCursors[userId]!;
    }
    
    
    activeMembers.removeWhere((m) {
      final lastSeen = m['lastSeen'] as DateTime;
      return DateTime.now().difference(lastSeen).inSeconds > 5;
    });
  }

  void _updatePresence() {
    if (!isCollaborating.value || activeRoomId.isEmpty || _roomChannel == null) return;
    final user = profileController.currentUser.value;
    if (user == null) return;

    _roomChannel!.sendBroadcastMessage(event: 'presence', payload: {
      'id': user.id,
      'name': user.name,
      'x': _lastLocalX,
      'y': _lastLocalY,
    });
  }

  double _lastLocalX = 0;
  double _lastLocalY = 0;

  void updateLocalCursor(Offset point) {
    _lastLocalX = point.dx;
    _lastLocalY = point.dy;
  }

  Timer? _interpolationTimer;
  void _startCursorInterpolation() {
    _interpolationTimer?.cancel();
    _interpolationTimer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!isCollaborating.value) {
        timer.cancel();
        return;
      }

      bool hasChanges = false;
      for (final userId in _targetCursors.keys) {
        final current = remoteCursors[userId] ?? Offset.zero;
        final target = _targetCursors[userId]!;
        
        if ((current - target).distance > 0.1) {
          
          remoteCursors[userId] = Offset.lerp(current, target, 0.2)!;
          hasChanges = true;
        }
      }
      
      if (hasChanges) remoteCursors.refresh();
    });
  }

  Future<void> uploadStroke(dynamic line) async {
    if (!isCollaborating.value || activeRoomId.isEmpty || _roomChannel == null) return;

    final user = profileController.currentUser.value;
    if (user == null) return;

    final Map<String, dynamic> data = line.toJson();

    _roomChannel!.sendBroadcastMessage(event: 'stroke', payload: {
      ...data,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'userId': user.id,
      'frameIndex': drawController.currentFrameIndex.value,
      'layerIndex': drawController.currentLayerIndex.value,
    });
  }

  void _handleRemoteStroke(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    if (userId == profileController.currentUser.value?.id) return;

    final line = DrawnLine.fromJson(data);
    final fIndex = data['frameIndex'] as int;
    final lIndex = data['layerIndex'] as int;

    if (fIndex < drawController.frames.length) {
      final frame = drawController.frames[fIndex];
      if (lIndex < frame.layers.length) {
        frame.layers[lIndex].lines.add(line);
        if (fIndex == drawController.currentFrameIndex.value) {
          drawController.updateBackgroundPicture();
        }
        drawController.frames.refresh();
      }
    }
  }
}
