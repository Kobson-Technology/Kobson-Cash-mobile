import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/config_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class MembershipPaymentScreen extends ConsumerStatefulWidget {
  const MembershipPaymentScreen({super.key});

  @override
  ConsumerState<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends ConsumerState<MembershipPaymentScreen> {
  bool _isLoading = false;
  String? _checkoutUrl;

  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);
    final apiClient = ref.read(apiClientProvider);

    try {
      final res = await apiClient.post('/api/v1/memberships');
      final checkoutUrl = res['checkoutUrl'] as String?;

      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        setState(() {
          _checkoutUrl = checkoutUrl;
          _isLoading = false;
        });

        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        throw Exception("URL de paiement introuvable dans la réponse.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _isLoading = true);
    final apiClient = ref.read(apiClientProvider);

    try {
      final verifyRes = await apiClient.post('/api/v1/memberships/verify');
      final isPaid = verifyRes is Map<String, dynamic> && verifyRes['hasActiveMembership'] == true;

      await ref.read(authProvider.notifier).checkAuthStatus();
      ref.invalidate(dashboardProvider);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Félicitations ! Votre paiement a été validé et votre adhésion est active.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun paiement confirmé reçu. Veuillez finaliser le règlement sur PayDunya.'),
            backgroundColor: AppColors.accentGold,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la vérification : $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Adhésion Kobson Cash'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (config) {
          final membershipAmount = config.membershipAmount;
          final c1 = config.commissionLevel1;
          final c2 = config.commissionLevel2;
          final c3 = config.commissionLevel3;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navyBlue, AppColors.primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.accentGold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Passez Membre Officiel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paiement unique de ${Formatters.formatCurrency(config.totalMembershipPayment)}',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (config.cashInFee > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '(${Formatters.formatCurrency(membershipAmount)} + ${Formatters.formatCurrency(config.cashInFee)} frais)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transparency Fee Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Détail du paiement',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Adhésion annuelle :', style: TextStyle(color: AppColors.textSecondary)),
                          Text(Formatters.formatCurrency(membershipAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Frais opérateur (${config.cashInFeePercent.toStringAsFixed(config.cashInFeePercent.truncateToDouble() == config.cashInFeePercent ? 0 : 1)}%) :',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          Text(Formatters.formatCurrency(config.cashInFee), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total à payer :', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text(
                            Formatters.formatCurrency(config.totalMembershipPayment),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Les frais de passerelle Mobile Money sont inclus directement pour garantir la viabilité sans dette de Kobson Cash.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Benefits
                const Text(
                  'Vos avantages membres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                _buildBenefitItem(
                  icon: Icons.account_tree_outlined,
                  title: 'Plan de rémunération à 3 niveaux',
                  subtitle: 'Gagnez ${Formatters.formatCurrency(c1)} (Niveau 1), ${Formatters.formatCurrency(c2)} (Niveau 2), et ${Formatters.formatCurrency(c3)} (Niveau 3).',
                ),
                _buildBenefitItem(
                  icon: Icons.mobile_friendly_outlined,
                  title: 'Paiements Mobile Money',
                  subtitle: 'Réglez simplement et retirez vos gains directement via Wave, Orange Money, MTN, Moov et Djamo.',
                ),
                _buildBenefitItem(
                  icon: Icons.qr_code_2_outlined,
                  title: 'Lien & QR Code exclusifs',
                  subtitle: 'Partagez votre code personnel avec vos contacts en un clic.',
                ),
                _buildBenefitItem(
                  icon: Icons.shield_outlined,
                  title: 'Sécurité & Traçabilité totale',
                  subtitle: 'Chaque centime est garanti et enregistré dans un grand livre financier infalsifiable.',
                ),

                const SizedBox(height: 32),

                if (_checkoutUrl == null) ...[
                  CustomButton(
                    text: 'Régler mon adhésion (${Formatters.formatCurrency(config.totalMembershipPayment)})',
                    icon: Icons.lock_outline,
                    isLoading: _isLoading,
                    onPressed: _initiatePayment,
                  ),
                ] else ...[
                  CustomButton(
                    text: 'Ouvrir la passerelle PayDunya',
                    icon: Icons.open_in_new,
                    onPressed: () async {
                      final uri = Uri.parse(_checkoutUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: "J'ai validé le paiement",
                    icon: Icons.check_circle_outline,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.successGreen,
                    onPressed: _checkPaymentStatus,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
