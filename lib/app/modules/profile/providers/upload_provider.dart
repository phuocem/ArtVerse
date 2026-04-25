import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artverse/app/data/services/security_service.dart';


class UploadProvider {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  final _securityService = Get.find<SecurityService>();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const int maxImageSize = 10 * 1024 * 1024;
  static const int maxVideoSize = 100 * 1024 * 1024;
  static const int maxProjectSize = 50 * 1024 * 1024;

  bool _validateFile(String filename, int fileSize, String contentType) {
    if (contentType.startsWith('image/')) {
      if (!_securityService.isValidImageFile(filename, fileSize)) {
        throw Exception('Invalid image file: size exceeds 10MB or unsupported format');
      }
    } else if (contentType.startsWith('video/')) {
      if (!_securityService.isValidVideoFile(filename, fileSize)) {
        throw Exception('Invalid video file: size exceeds 100MB or unsupported format');
      }
    } else if (contentType == 'application/json') {
      if (!_securityService.isValidProjectFile(filename, fileSize)) {
        throw Exception('Invalid project file: size exceeds 50MB or unsupported format');
      }
    } else {
      throw Exception('Unsupported file type: $contentType');
    }
    return true;
  }

  Future<void> uploadToSupabase({
    required String bucket,
    required String path,
    required List<int> bytes,
    required String contentType,
    required String filename,
  }) async {
    _validateFile(filename, bytes.length, contentType);
    final sanitizedPath = _securityService.sanitizeFilePath(path);
    
    if (!_securityService.checkRateLimit('upload_$bucket', maxAttempts: 10, window: const Duration(minutes: 5))) {
      throw Exception('Upload rate limit exceeded. Please try again later.');
    }

    try {
      
      await _supabase.storage.from(bucket).uploadBinary(
        sanitizedPath,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );
    } catch (e) {
      throw Exception('Supabase upload failed: $e');
    }
  }

  String getSupabasePublicUrl(String bucket, String path) {
    final sanitizedPath = _securityService.sanitizeFilePath(path);
    final url = '$supabaseUrl/storage/v1/object/public/$bucket/$sanitizedPath';
    if (!_securityService.isValidUrl(url)) {
      throw Exception('Invalid URL generated');
    }
    return url;
  }

  Future<void> savePostToSupabase(Map<String, dynamic> data) async {
    if (data['name'] != null) {
      data['name'] = _securityService.sanitizeText(data['name'] as String, maxLength: 100);
    }
    if (data['description'] != null) {
      data['description'] = _securityService.sanitizeText(data['description'] as String, maxLength: 2000);
    }
    if (data['author_name'] != null) {
      data['author_name'] = _securityService.sanitizeText(data['author_name'] as String, maxLength: 50);
    }
    if (data['name'] == null || (data['name'] as String).trim().isEmpty) {
      data['name'] = 'Untitled Artwork';
    }
    if (data['user_id'] == null || (data['user_id'] as String).isEmpty) {
      throw Exception('User ID is required');
    }
    try {
      await _supabase
          .from('posts')
          .insert(data)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      rethrow;
    }
  }
}
