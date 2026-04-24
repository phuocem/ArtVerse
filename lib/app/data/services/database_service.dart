import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/draw/offset_adapter.dart';
import '../models/draw/draw_project_model.dart';
import '../models/draw/drawn_line_model.dart';
import '../models/draw/frame_model.dart';
import '../models/draw/layer_model.dart';
import '../models/user_model.dart';

class DatabaseService extends GetxService {
  late Box<DrawProjectModel> drawProjectBox;
  late Box<UserModel> userBox;
  late Box<dynamic> settingsBox;
  late Box<dynamic> syncBox;
  final _secureStorage = const FlutterSecureStorage();

  Future<DatabaseService> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(OffsetAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(BrushTypeAdapter());
    Hive.registerAdapter(SymmetryTypeAdapter());
    Hive.registerAdapter(DrawnLineAdapter());
    Hive.registerAdapter(LayerModelAdapter());
    Hive.registerAdapter(FrameModelAdapter());
    Hive.registerAdapter(DrawProjectModelAdapter());
    final encryptionKey = await _getEncryptionKey();
    try {
      settingsBox = await Hive.openBox<dynamic>(
        'settings',
        encryptionCipher: HiveAesCipher(encryptionKey),
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw "Settings box timeout");
      drawProjectBox = await Hive.openBox<DrawProjectModel>(
        'draw_project',
        encryptionCipher: HiveAesCipher(encryptionKey),
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw "DrawProject box timeout");
      userBox = await Hive.openBox<UserModel>(
        'users',
        encryptionCipher: HiveAesCipher(encryptionKey),
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw "User box timeout");
      syncBox = await Hive.openBox<dynamic>(
        'sync_queue',
        encryptionCipher: HiveAesCipher(encryptionKey),
      ).timeout(const Duration(seconds: 10), onTimeout: () => throw "Sync box timeout");
    } catch (e) {
      await Hive.deleteBoxFromDisk('settings');
      await Hive.deleteBoxFromDisk('draw_project');
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('sync_queue');
      settingsBox = await Hive.openBox<dynamic>('settings');
      drawProjectBox = await Hive.openBox<DrawProjectModel>('draw_project');
      userBox = await Hive.openBox<UserModel>('users');
      syncBox = await Hive.openBox<dynamic>('sync_queue');
    }
    return this;
  }

  Future<List<int>> _getEncryptionKey() async {
    const keyName = 'hive_encryption_key';
    try {
      final containsKey = await _secureStorage.containsKey(key: keyName)
          .timeout(const Duration(seconds: 3), onTimeout: () => throw "Secure storage timeout");
      if (!containsKey) {
        final key = Hive.generateSecureKey();
        await _secureStorage.write(key: keyName, value: base64UrlEncode(key))
            .timeout(const Duration(seconds: 3), onTimeout: () => throw "Secure storage write timeout");
      }
      final encodedKey = await _secureStorage.read(key: keyName)
          .timeout(const Duration(seconds: 3), onTimeout: () => throw "Secure storage read timeout");
      return base64Url.decode(encodedKey!);
    } catch (e) {
      
      
      throw Exception("FATAL: Không thể khởi tạo hoặc truy cập khóa bảo mật cho cơ sở dữ liệu. Dữ liệu của bạn được bảo vệ nên không thể mở ở chế độ không an toàn.");
    }
  }
}
