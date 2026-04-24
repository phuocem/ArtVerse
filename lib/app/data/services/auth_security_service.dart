import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AuthSecurityService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _sessionRefreshTimer;
  static const Duration sessionRefreshInterval = Duration(minutes: 50);

  @override
  void onInit() {
    super.onInit();
    _setupAuthStateListener();
    _startSessionRefreshTimer();
  }

  void _setupAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        if (kDebugMode) debugPrint('✅ User authenticated: ${session.user.id}');
      } else {
        if (kDebugMode) debugPrint('❌ User signed out');
        _stopTimers();
      }
    });
  }

  void _startSessionRefreshTimer() {
    _sessionRefreshTimer?.cancel();
    _sessionRefreshTimer = Timer.periodic(sessionRefreshInterval, (_) async {
      await refreshSession();
    });
  }

  void _stopTimers() => _sessionRefreshTimer?.cancel();

  Future<void> refreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _supabase.auth.refreshSession();
        if (kDebugMode) debugPrint('✅ Session refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Session refresh failed: $e');
    }
  }

  Future<String?> getValidToken() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) return session.accessToken;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to get token: $e');
    }
    return null;
  }

  Future<void> secureSignOut() async {
    try {
      _stopTimers();
      await _supabase.auth.signOut();
      if (kDebugMode) debugPrint('✅ Secure sign out completed');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Secure sign out failed: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }
}
