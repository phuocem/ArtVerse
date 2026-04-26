import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/wallet_controller.dart';
class WalletView extends GetView<WalletController> {
  const WalletView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Text('Wallet', style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.toNamed<void>('/marketplace/upload'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.violetPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Sell Assets', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _BalanceCard(controller: controller)),
                        const SizedBox(width: 16),
                        Expanded(child: _MembershipCard(controller: controller)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('TRANSACTION HISTORY', style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textTertiary, fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 14),
                    Obx(() {
                      final txs = controller.transactions;
                      if (txs.isEmpty) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined,
                                    size: 36, color: AppColors.textTertiary),
                                const SizedBox(height: 8),
                                Text('No transactions yet', style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textTertiary, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: txs.asMap().entries.map((e) {
                          return _TxRow(tx: e.value, index: e.key);
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
class _BalanceCard extends StatelessWidget {
  final WalletController controller;
  const _BalanceCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.violetPink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BALANCE', style: GoogleFonts.ibmPlexMono(
            color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('\$${controller.balance.value.toStringAsFixed(2)}',
            style: GoogleFonts.lexend(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Available for withdrawal', style: GoogleFonts.plusJakartaSans(
            color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Get.snackbar('Withdraw', 'Withdrawal feature coming soon.',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.surface2,
              colorText: AppColors.textPrimary),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30),
              ),
              child: Text('WITHDRAW →', style: GoogleFonts.ibmPlexMono(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms));
  }
}
class _MembershipCard extends StatelessWidget {
  final WalletController controller;
  const _MembershipCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isStudio = controller.isStudio.value;
      final days = controller.daysRemaining.value;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isStudio ? AppColors.amber.withValues(alpha: 0.4) : AppColors.border,
            width: isStudio ? 1 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isStudio ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
                    color: isStudio ? AppColors.amber : AppColors.textTertiary, size: 20),
                const SizedBox(width: 8),
                Text(isStudio ? 'Studio Member' : 'Free Tier',
                  style: GoogleFonts.lexend(
                    color: isStudio ? AppColors.amber : AppColors.textPrimary,
                    fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            if (isStudio) ...[
              Text('$days days remaining', style: GoogleFonts.ibmPlexMono(
                color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (days / 30).clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text('Unlimited projects · No watermarks\nPriority support · Advanced tools',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11, height: 1.6)),
            ] else ...[
              Text('Upgrade to unlock all features', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary, fontSize: 12)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.toNamed<void>('/studio-upgrade'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGrad,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('UPGRADE TO STUDIO', style: GoogleFonts.ibmPlexMono(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ],
        ),
      );
    }).animate().fadeIn(duration: 500.ms);
  }
}
class _TxRow extends StatelessWidget {
  final Map<String, dynamic> tx;
  final int index;
  const _TxRow({required this.tx, required this.index});
  @override
  Widget build(BuildContext context) {
    final type = tx['type'] as String? ?? 'credit';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final desc = tx['description'] as String? ?? 'Transaction';
    final date = tx['created_at'] as String? ?? '';
    final isCredit = type == 'credit' || amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.teal.withValues(alpha: 0.1) : AppColors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.teal : AppColors.pink, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                if (date.isNotEmpty)
                  Text(date.substring(0, date.length > 10 ? 10 : date.length),
                    style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 9)),
              ],
            ),
          ),
          Text('${isCredit ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.lexend(
              color: isCredit ? AppColors.teal : AppColors.pink,
              fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn(duration: 300.ms);
  }
}
