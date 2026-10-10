import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../membership/screens/membership_payment_screen.dart';
import '../providers/wallet_provider.dart';
import 'transactions_screen.dart';
import '../../withdrawals/screens/withdrawal_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _showChestLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Coffre Verrouillé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Les retraits sont réservés aux membres ayant activé leur Coffre aux Gains (4 500 FCFA). Obtenez votre Clé d\'Or pour débloquer les décaissements Mobile Money.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembershipPaymentScreen()),
              );
            },
            icon: const Icon(Icons.vpn_key_rounded, size: 18),
            label: const Text('Obtenir la Clé', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);
    final hasChest = ref.watch(authProvider).user?.hasActiveMembership ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Portefeuille'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(walletProvider);
              ref.invalidate(walletTransactionsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(walletTransactionsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              walletAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
                data: (wallet) => Column(
                  children: [
                    BalanceCard(
                      availableBalance: wallet.availableBalance,
                      heldBalance: wallet.heldBalance,
                      currency: wallet.currency,
                      hasActiveMembership: hasChest,
                      onWithdrawPressed: () {
                        if (!hasChest) {
                          _showChestLockedDialog(context);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WithdrawalScreen()),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    // Hold Explanation Card
                    if (wallet.heldBalance > 0)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.accentGold, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${Formatters.formatCurrency(wallet.heldBalance)} sont actuellement réservés pour un retrait en cours de traitement.',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF78350F)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ledger Transactions Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Écritures du grand livre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                      );
                    },
                    child: const Text('Tout voir'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              txAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Erreur: $err'),
                data: (txList) {
                  if (txList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Aucune écriture enregistrée pour le moment.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  final displayList = txList.take(5).toList();
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
                      itemBuilder: (context, index) {
                        final tx = displayList[index];
                        final isCredit = tx.type.toLowerCase().contains('commission');
                        final isHold = tx.type.toLowerCase().contains('hold');

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: isHold
                                ? AppColors.accentGold.withValues(alpha: 0.12)
                                : (isCredit ? AppColors.successGreen.withValues(alpha: 0.12) : AppColors.errorRed.withValues(alpha: 0.12)),
                            child: Icon(
                              isHold
                                  ? Icons.lock_clock_outlined
                                  : (isCredit ? Icons.arrow_downward : Icons.arrow_upward),
                              size: 18,
                              color: isHold
                                  ? AppColors.accentGold
                                  : (isCredit ? AppColors.successGreen : AppColors.errorRed),
                            ),
                          ),
                          title: Text(
                            Formatters.formatTransactionType(tx.type),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            Formatters.formatDateTime(tx.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? "+" : (isHold ? "" : "-")}${Formatters.formatCurrency(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isHold
                                      ? AppColors.accentGold
                                      : (isCredit ? AppColors.successGreen : AppColors.errorRed),
                                ),
                              ),
                              Text(
                                tx.reference,
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Demander un retrait',
                icon: Icons.account_balance_wallet_outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WithdrawalScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
