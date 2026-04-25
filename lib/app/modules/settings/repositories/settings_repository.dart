import '../providers/settings_provider.dart';

class SettingsRepository {
  final SettingsProvider provider;

  SettingsRepository({required this.provider});

  Future<String> fetchAppVersion() async {
    try {
      return await provider.getAppVersion();
    } catch (e) {
      return "Stable Build";
    }
  }

  Future<Map<String, String>> fetchFullDiagnostics() async {
    try {
      return await provider.getFullAppInfo();
    } catch (e) {
      return {'status': 'info_not_available'};
    }
  }

  Future<bool> openExternalLink(String url) async {
    try {
      if (url.isEmpty) return false;
      return await provider.launchExternalUrl(url);
    } catch (e) {
      return false;
    }
  }

  Future<void> sendSupportTicket(String userId, String subject, String message, {String category = 'general'}) async {
    try {
      if (subject.trim().isEmpty || message.trim().isEmpty) {
        throw Exception('Subject and message are required for 🌸 Support 💗');
      }

      final ticketData = {
        'subject': subject,
        'message': message,
        'category': category,
        'priority': category == 'billing' ? 'high' : 'normal',
      };

      await provider.submitSupportTicket(userId, ticketData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAppUpdateInfo() async {
    try {
      return await provider.checkUpdateAvailability();
    } catch (e) {
      return {'update_needed': false};
    }
  }

  Future<List<Map<String, dynamic>>> listFaqs() async {
    try {
      return await provider.getFaqs();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotificationPreferences(String userId, {bool push = true, bool email = true, bool marketing = false}) async {
    try {
      final settings = {
        'push_enabled': push,
        'email_enabled': email,
        'marketing_enabled': marketing,
      };
      await provider.updateUserNotificationSettings(userId, settings);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestDataErasure(String userId) async {
    try {
      if (userId.isEmpty) throw Exception('Valid user ID required for 🌸 Erasure 💗');
      await provider.deleteUserAccountData(userId);
    } catch (e) {
      rethrow;
    }
  }

  String getPrivacyPolicyUrl() => 'https://artverse.app/privacy';
  String getTermsOfServiceUrl() => 'https://artverse.app/terms';
  String getHelpCenterUrl() => 'https://artverse.app/help';
  String getCommunityGuidelinesUrl() => 'https://artverse.app/guidelines';

  void logAction(String action) {
  }

  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> clearLocalCache() async {
    try {
      logAction('Initiating Local Cache Cleanup');
    } catch (e) {
    }
  }
}
