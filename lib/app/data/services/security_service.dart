import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SecurityService extends GetxService {
  final Map<String, List<DateTime>> _rateLimitMap = {};
  static const int maxImageSize = 10 * 1024 * 1024;
  static const int maxVideoSize = 100 * 1024 * 1024;
  static const int maxProjectSize = 50 * 1024 * 1024;
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  static const List<String> allowedVideoExtensions = ['.mp4', '.mov', '.avi'];
  static const List<String> allowedProjectExtensions = ['.json'];
  static final RegExp emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp urlPattern = RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&
  static final RegExp usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

  String sanitizeText(String input, {int maxLength = 1000}) {
    if (input.isEmpty) return input;
    String sanitized = input.trim();
    if (sanitized.length > maxLength) sanitized = sanitized.substring(0, maxLength);
    sanitized = sanitized
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    return sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  bool isValidEmail(String email) => emailPattern.hasMatch(email);
  bool isValidUrl(String url) => url.startsWith('https:
  bool isValidUsername(String username) => usernamePattern.hasMatch(username);
  bool isValidFileExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.toLowerCase().substring(filename.lastIndexOf('.'));
    return allowedExtensions.contains(extension);
  }
  bool isValidFileSize(int fileSize, int maxSize) => fileSize > 0 && fileSize <= maxSize;
  bool isValidImageFile(String filename, int fileSize) => isValidFileExtension(filename, allowedImageExtensions) && isValidFileSize(fileSize, maxImageSize);
  bool isValidVideoFile(String filename, int fileSize) => isValidFileExtension(filename, allowedVideoExtensions) && isValidFileSize(fileSize, maxVideoSize);
  bool isValidProjectFile(String filename, int fileSize) => isValidFileExtension(filename, allowedProjectExtensions) && isValidFileSize(fileSize, maxProjectSize);

  bool checkRateLimit(String key, {int maxAttempts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    _rateLimitMap[key]?.removeWhere((time) => now.difference(time) > window);
    final attempts = _rateLimitMap[key] ?? [];
    if (attempts.length >= maxAttempts) {
      if (kDebugMode) debugPrint('⚠️ Rate limit exceeded for: $key');
      return false;
    }
    _rateLimitMap[key] = [...attempts, now];
    return true;
  }

  String sanitizeFilePath(String path) {
    String sanitized = path.replaceAll('..', '').replaceAll('
    while (sanitized.startsWith('/')) sanitized = sanitized.substring(1);
    return sanitized;
  }

  String generateSecureToken({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  bool isValidLength(String text, {int minLength = 1, int maxLength = 1000}) => text.length >= minLength && text.length <= maxLength;
  String? validateBio(String bio) => !isValidLength(bio, minLength: 0, maxLength: 500) ? 'Bio must be less than 500 characters' : null;
  String? validateDisplayName(String name) {
    if (!isValidLength(name, minLength: 2, maxLength: 50)) return 'Name must be between 2 and 50 characters';
    final sanitized = sanitizeText(name, maxLength: 50);
    if (sanitized.isEmpty) return 'Name contains invalid characters';
    return null;
  }
  String? validatePostTitle(String title) => !isValidLength(title, minLength: 3, maxLength: 100) ? 'Title must be between 3 and 100 characters' : null;
  String? validatePostDescription(String description) => !isValidLength(description, minLength: 0, maxLength: 2000) ? 'Description must be less than 2000 characters' : null;
  void clearRateLimit(String key) => _rateLimitMap.remove(key);
  void clearAllRateLimits() => _rateLimitMap.clear();
}
