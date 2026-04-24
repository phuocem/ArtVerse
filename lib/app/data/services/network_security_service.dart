import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class NetworkSecurityService {
  static NetworkSecurityService? _instance;
  late http.Client _client;
  NetworkSecurityService._();
  static NetworkSecurityService get instance {
    _instance ??= NetworkSecurityService._();
    return _instance!;
  }

  void initialize() {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) {
      if (kDebugMode) debugPrint('⚠️ Certificate validation for $host:$port');
      return false;
    };
    httpClient.connectionTimeout = const Duration(seconds: 30);
    httpClient.idleTimeout = const Duration(seconds: 15);
    _client = IOClient(httpClient);
  }

  http.Client get client => _client;

  Future<http.Response> secureGet(Uri url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 30)}) async {
    if (url.scheme != 'https') throw SecurityException('Only HTTPS requests are allowed');
    try {
      return await _client.get(url, headers: headers).timeout(timeout);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Secure GET request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> securePost(Uri url, {Map<String, String>? headers, Object? body, Duration timeout = const Duration(seconds: 30)}) async {
    if (url.scheme != 'https') throw SecurityException('Only HTTPS requests are allowed');
    try {
      return await _client.post(url, headers: headers, body: body).timeout(timeout);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Secure POST request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> securePut(Uri url, {Map<String, String>? headers, Object? body, Duration timeout = const Duration(seconds: 30)}) async {
    if (url.scheme != 'https') throw SecurityException('Only HTTPS requests are allowed');
    try {
      return await _client.put(url, headers: headers, body: body).timeout(timeout);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Secure PUT request failed: $e');
      rethrow;
    }
  }

  Future<http.Response> secureDelete(Uri url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 30)}) async {
    if (url.scheme != 'https') throw SecurityException('Only HTTPS requests are allowed');
    try {
      return await _client.delete(url, headers: headers).timeout(timeout);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Secure DELETE request failed: $e');
      rethrow;
    }
  }

  void dispose() => _client.close();
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}
