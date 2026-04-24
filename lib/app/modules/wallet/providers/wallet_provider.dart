import 'package:supabase_flutter/supabase_flutter.dart';

class WalletProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateWalletBalance(String userId, double newBalance) async {
    try {
      await _supabase.from('users').update({
        'balance': newBalance,
        'edited_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> upgradeToStudio(String userId, double newBalance) async {
    try {
      await _supabase.from('users').update({
        'balance': newBalance,
        'is_studio': true,
        'studio_started_at': DateTime.now().toUtc().toIso8601String(),
        'studio_expires_at': DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String(),
      }).eq('id', userId);

      await _supabase.from('transactions').insert({
        'user_id': userId,
        'type': 'upgrade_studio',
        'amount': -35.0,
        'description': '🌸 Upgraded to ArtVerse Studio 💗',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordTransaction(String userId, Map<String, dynamic> txData) async {
    try {
      await _supabase.from('transactions').insert({
        ...txData,
        'user_id': userId,
      });
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> claimDailyReward(String userId, double rewardAmount) async {
    try {
      
      final user = await _supabase
          .from('users')
          .select('balance')
          .eq('id', userId)
          .single();
      final currentBalance = (user['balance'] as num?)?.toDouble() ?? 0.0;

      await _supabase.from('users').update({
        'balance': currentBalance + rewardAmount,
        'last_claim_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      await _supabase.from('transactions').insert({
        'user_id': userId,
        'type': 'daily_reward',
        'amount': rewardAmount,
        'description': '🌸 Daily ArtVerse Bonus 💗',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getWalletMetadata(String userId) async {
    try {
      return await _supabase
          .from('users')
          .select('balance, is_studio, studio_started_at, studio_expires_at, last_claim_at')
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initiateWithdrawal(String userId, double amount, String method) async {
    try {
      await _supabase.from('withdrawal_requests').insert({
        'user_id': userId,
        'amount': amount,
        'method': method,
        'status': 'pending',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> buyArtCoins(String userId, double amount, double cost) async {
    try {
      
      final user = await _supabase
          .from('users')
          .select('balance')
          .eq('id', userId)
          .single();
      final currentBalance = (user['balance'] as num?)?.toDouble() ?? 0.0;

      await _supabase.from('users').update({
        'balance': currentBalance + amount,
      }).eq('id', userId);

      await _supabase.from('transactions').insert({
        'user_id': userId,
        'type': 'buy_coins',
        'amount': amount,
        'cost': cost,
        'description': '🌸 Purchased ArtCoins 💗',
      });
    } catch (e) {
      rethrow;
    }
  }
}
