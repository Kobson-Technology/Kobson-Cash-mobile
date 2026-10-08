import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config/config_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/referral_provider.dart';
import 'my_team_screen.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(referralTreeProvider);
    final configAsync = ref.watch(configProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Parrainage & Réseau'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyTeamScreen()),
              );
            },
          ),
        ],
      ),
      body: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (tree) {
          final code = tree.myReferralCode;
          final link = tree.shareUrl.isNotEmpty
              ? tree.shareUrl
              : 'https://cash.kobsontech.com/?ref=$code';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // QR Code and Code Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Votre Clé de Parrainage',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              code,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppColors.primaryBlue, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Clé de parrainage copiée !'),
                                    backgroundColor: AppColors.primaryBlue,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: QrImageView(
                          data: link,
                          version: QrVersions.auto,
                          size: 160.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Faites scanner ce QR Code ou partagez votre lien pour parrainer un proche.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Share Buttons
                CustomButton(
                  text: 'Partager mon lien d’invitation',
                  icon: Icons.share_rounded,
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Rejoins Kobson Cash et génère des revenus d’affiliation fiables et sécurisés ! Mon code : $code. Inscris-toi ici : $link',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 3 Levels Commission Plan Info
                configAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (config) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plan de Rémunération 3 Niveaux',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLevelRewardRow(
                          level: 'Niveau 1 (Directs)',
                          amount: Formatters.formatCurrency(config.commissionLevel1),
                          count: tree.level1Count,
                          color: AppColors.primaryBlue,
                        ),
                        const Divider(height: 20),
                        _buildLevelRewardRow(
                          level: 'Niveau 2 (Affiliés)',
                          amount: Formatters.formatCurrency(config.commissionLevel2),
                          count: tree.level2Count,
                          color: AppColors.accentGold,
                        ),
                        const Divider(height: 20),
                        _buildLevelRewardRow(
                          level: 'Niveau 3 (Équipe)',
                          amount: Formatters.formatCurrency(config.commissionLevel3),
                          count: tree.level3Count,
                          color: AppColors.successGreen,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Team Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.groups_outlined, color: AppColors.primaryBlue),
                  label: Text(
                    'Voir mon équipe (${tree.totalTeamCount} membres)',
                    style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyTeamScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelRewardRow({
    required String level,
    required String amount,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('$count membre(s)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(
          '+$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}
