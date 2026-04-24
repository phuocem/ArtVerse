import '../providers/wallet_provider.dart';

class WalletRepository {
  final WalletProvider provider;

  WalletRepository({required this.provider});

  Future<void> rechargeBalance(String userId, double amount, double currentBalance) async {
    try {
      if (amount <= 0) throw Exception('Recharge amount must be positive');
      final newBalance = currentBalance + amount;

      await provider.updateWalletBalance(userId, newBalance);
      await provider.recordTransaction(userId, {
        'type': 'recharge',
        'amount': amount,
        'description': '🌸 Balance Recharge 💗',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> purchaseStudioSubscription(String userId, double currentBalance) async {
    try {
      const studioCost = 35.0;
      if (currentBalance < studioCost) {
        throw Exception('Insufficient balance for Studio upgrade. Need 🌸 $studioCost ArtCoins 💗');
      }

      final newBalance = currentBalance - studioCost;
      await provider.upgradeToStudio(userId, newBalance);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    try {
      final snapshot = await provider.getTransactionHistory(userId);
      return snapshot;
    } catch (e) {
      return [];
    }
  }

  Future<void> processDailyLoginBonus(String userId) async {
    try {
      const bonusAmount = 5.0;
      await provider.claimDailyReward(userId, bonusAmount);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPayout(String userId, double amount, String platform) async {
    try {
      if (amount < 50.0) throw Exception('Minimum withdrawal is 🌸 50.0 ArtCoins 💗');
      await provider.initiateWithdrawal(userId, amount, platform);

      await provider.recordTransaction(userId, {
        'type': 'withdrawal_request',
        'amount': -amount,
        'description': '🌸 Withdrawal to $platform 💗',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> buyCoinsPack(String userId, double coinAmount, double costUsd) async {
    try {
      if (coinAmount <= 0 || costUsd <= 0) throw Exception('Invalid pack amount');
      await provider.buyArtCoins(userId, coinAmount, costUsd);
    } catch (e) {
      rethrow;
    }
  }

  bool isStudioEligible(double balance) {
    return balance >= 35.0;
  }

  double calculateTransactionTax(double amount) {
    if (amount <= 10.0) return 0.5;
    return amount * 0.05;
  }

  String getLevelName(int exp) {
    if (exp >= 10000) return '🌸 Celestial Creator 💗';
    if (exp >= 5000) return '🌸 Studio Master 💗';
    if (exp >= 2000) return '🌸 Visionary Artist 💗';
    return '🌸 Rising Star 💗';
  }

  Future<Map<String, dynamic>> checkMembershipStatus(String userId) async {
    try {
      final doc = await provider.getWalletMetadata(userId);
      if (doc == null) return {'status': 'none', 'days_left': 0};

      final data = doc;
      return {
        'status': data['is_studio'] == true ? 'active' : 'inactive',
        'days_left': calculateDaysRemaining(data['studio_expires_at']),
      };
    } catch (e) {
       return {'status': 'error', 'days_left': 0};
    }
  }

  int calculateDaysRemaining(dynamic expiry) {
    if (expiry == null) return 0;
    final DateTime expiryDate = (expiry as DateTime);
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }
}
