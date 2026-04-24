import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: lc.backgroundColor)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(lc),
              _buildWalletCard(lc),
              _buildDailyRewardSection(lc),
              _buildStudioMembership(lc),
              _buildSectionTitle("recharge_artcoins", lc),
              _buildRechargeGrid(lc),
              _buildSectionTitle("transaction_history", lc),
              _buildTransactionList(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 150)),
            ],
          ),

          Positioned(
            top: 40,
            left: 40,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lc.cardColor.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: lc.glassBorderColor),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: lc.textColor, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 100, 40, 32),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'artcoin_wallet'.tr.toUpperCase(),
              style: TextStyle(
                color: lc.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'wallet_title'.tr,
              style: TextStyle(
                color: lc.textColor,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: lc.accentGradient,
          boxShadow: [
            BoxShadow(
              color: lc.primaryColor.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -50,
              child: Icon(
                Icons.stars_rounded,
                size: 280,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "current_holdings".tr.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 32),
                      const SizedBox(width: 12),
                      Obx(() => Text(
                        "${controller.balance.value.toInt()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("artcoins_available".tr, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRewardSection(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 32, 40, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Color(0xFF10B981), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "daily_bonus_ready".tr.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    Text(
                      "claim_daily_desc".tr,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.claimDaily,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("claim".tr.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudioMembership(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final isStudio = controller.isStudio.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(40, 24, 40, 48),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: lc.glassColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isStudio ? const Color(0xFF10B981).withValues(alpha: 0.3) : lc.glassBorderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isStudio ? const Color(0xFF10B981) : const Color(0xFFFF1493)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isStudio ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                  color: isStudio ? const Color(0xFF10B981) : lc.primaryColor,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStudio ? "artverse_studio_active".tr.toUpperCase() : "upgrade_to_studio".tr.toUpperCase(),
                      style: TextStyle(
                        color: lc.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStudio 
                        ? "${'days_remaining'.tr}: ${controller.daysRemaining.value}" 
                        : "unlock_studio_desc".tr,
                      style: TextStyle(color: lc.subtextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
                ElevatedButton(
                  onPressed: controller.upgradeToStudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lc.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('35 ART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String titleKey, LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
      sliver: SliverToBoxAdapter(
        child: Text(
          titleKey.tr.toUpperCase(),
          style: TextStyle(
            color: lc.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeGrid(LayoutController lc) {
    final packages = [
      {'coins': 10, 'price': '\$0.99', 'icon': Icons.flash_on_rounded, 'color': Colors.blue},
      {'coins': 50, 'price': '\$4.99', 'icon': Icons.bolt_rounded, 'color': Colors.orange},
      {'coins': 100, 'price': '\$8.99', 'icon': Icons.rocket_launch_rounded, 'color': const Color(0xFFFF69B4)},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.2,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final pkg = packages[index];
          return _buildPackageItem(
            pkg['coins'] as int,
            pkg['price'] as String,
            pkg['icon'] as IconData,
            pkg['color'] as Color,
            lc,
          );
        }, childCount: packages.length),
      ),
    );
  }

  Widget _buildPackageItem(int coins, String price, IconData icon, Color color, LayoutController lc) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _showPaymentMethods(context, coins, price, lc),
      child: Container(
        decoration: BoxDecoration(
          color: lc.glassColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: lc.glassBorderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              "$coins ART",
              style: TextStyle(color: lc.textColor, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(price, style: TextStyle(color: lc.subtextColor, fontSize: 13)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTransactionList(LayoutController lc) {
    return Obx(() {
      final txList = controller.transactions;
      if (txList.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                "no_recent_activity".tr.toUpperCase(),
                style: TextStyle(color: lc.subtextColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final tx = txList[index];
          final isCredit = (tx['amount'] ?? 0) >= 0;
          return Container(
            margin: const EdgeInsets.fromLTRB(40, 0, 40, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: lc.glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lc.glassBorderColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isCredit ? Colors.green : Colors.redAccent).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                    color: isCredit ? Colors.green : Colors.redAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['description'] ?? "transaction".tr,
                        style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tx['created_at'] != null 
                          ? DateFormat('MMM d, HH:mm').format(DateTime.parse(tx['created_at'].toString()))
                          : 'recent'.tr,
                        style: TextStyle(color: lc.subtextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isCredit ? '+' : ''}${tx['amount']} ART",
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }, childCount: txList.length),
      );
    });
  }

  void _showPaymentMethods(BuildContext context, int coins, String price, LayoutController lc) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: lc.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: lc.glassBorderColor, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("select_payment".tr.toUpperCase(), style: TextStyle(color: lc.primaryColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text("Total: $price", style: TextStyle(color: lc.textColor, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
            const SizedBox(height: 32),
            _buildPaymentOption(
              "MoMo E-Wallet", 
              Icons.account_balance_wallet_rounded, 
              const Color(0xFFA50064), 
              lc, 
              () => _processPayment(coins, isMomo: true),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              "Credit / Debit Card", 
              Icons.credit_card_rounded, 
              Colors.blueAccent, 
              lc, 
              () => _processPayment(coins),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              "Apple Pay", 
              Icons.apple_rounded, 
              lc.textColor, 
              lc, 
              () => _processPayment(coins),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, Color color, LayoutController lc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: lc.glassColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: lc.glassBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(name, style: TextStyle(color: lc.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: lc.subtextColor),
          ],
        ),
      ),
    );
  }

  void _processPayment(int coins, {bool isMomo = false}) {
    Get.back(); 
    if (isMomo) {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFA50064),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA50064).withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48, height: 48,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Redirecting to MoMo...", 
                  style: TextStyle(
                    color: Colors.white, 
                    decoration: TextDecoration.none, 
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  )
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (Get.isDialogOpen ?? false) Get.back();
        controller.recharge(coins.toDouble());
      });
    } else {
      controller.recharge(coins.toDouble());
    }
  }
}
