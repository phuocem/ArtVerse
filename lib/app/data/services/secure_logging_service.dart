import 'package:flutter/foundation.dart';

class SecureLoggingService {


  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
    }
  }

  static void error(String message, {Object? error, String? tag}) {
    if (kDebugMode) {
      if (error != null) debugPrint('   Error type: ${error.runtimeType}');
    }
  }

  static void success(String message, {String? tag}) {
    if (kDebugMode) {
    }
  }

  static void security(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      if (details != null) {
      }
    }
  }

  static void network(String method, String url, {int? statusCode, String? tag}) {
    if (kDebugMode) {
    }
  }

  static void performance(String operation, Duration duration, {String? tag}) {
    if (kDebugMode) {
    }
  }
}
