import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SettingsProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return "${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      return "1.0.0+1";
    }
  }

  Future<Map<String, String>> getFullAppInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return {
        'appName': info.appName,
        'packageName': info.packageName,
        'version': info.version,
        'buildNumber': info.buildNumber,
        'platform': Platform.operatingSystem,
      };
    } catch (e) {
      return {};
    }
  }

  Future<bool> launchExternalUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> submitSupportTicket(String userId, Map<String, dynamic> ticketData) async {
    try {
      await _supabase.from('support_tickets').insert({
        'user_id': userId,
        'data': ticketData,
        'status': 'open',
        'app_version': await getAppVersion(),
        'platform': Platform.operatingSystem,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkUpdateAvailability() async {
    try {
      final response = await _supabase
          .from('app_config')
          .select('value')
          .eq('key', 'version')
          .maybeSingle();
      if (response == null) return {'update_needed': false};

      final data = response['value'] as Map<String, dynamic>;
      final latestVersion = data['latest'] as String;
      final currentVersion = (await PackageInfo.fromPlatform()).version;

      return {
        'update_needed': latestVersion != currentVersion,
        'latest_version': latestVersion,
        'critical': data['critical'] ?? false,
        'url': data['url'] ?? '',
      };
    } catch (e) {
      return {'update_needed': false};
    }
  }

  Future<List<Map<String, dynamic>>> getFaqs() async {
    try {
      final response = await _supabase
          .from('faqs')
          .select()
          .order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [
        {'q': 'How to earn ArtCoins?', 'a': 'Complete daily challenges and participate in community events.'},
        {'q': 'Is ArtVerse Studio permanent?', 'a': 'Yes, lifetime access is unlocked with a one-time payment.'},
      ];
    }
  }

  Future<void> updateUserNotificationSettings(String userId, Map<String, bool> settings) async {
    try {
      await _supabase.from('users').update({
        'notification_settings': settings,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserAccountData(String userId) async {
    try {
      
      await _supabase.from('users').update({
        'is_active': false,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      await _supabase.from('deletion_requests').insert({
        'user_id': userId,
        'status': 'pending',
      });
    } catch (e) {
      rethrow;
    }
  }
}
