import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/config_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/animated_glowing_chest.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/widgets/operator_brand_logo.dart';

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

        await _openPayDunya(checkoutUrl);
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

  Future<void> _openPayDunya(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir la page de paiement : $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
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
            content: Text('Félicitations ! Votre Coffre est maintenant activé et prêt à recevoir vos gains.'),
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
        title: const Text('Obtenir la Clé du Coffre'),
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
                // Header Card with Animated Glowing Chest & Key
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AnimatedGlowingChest(
                        size: 130,
                        hasKey: false,
                        showBadge: false,
                        showFloatingKey: true,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Obtenez la Clé & Ouvrez votre Coffre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Paiement unique de ${Formatters.formatCurrency(config.totalMembershipPayment)}',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.vpn_key_rounded, color: AppColors.accentGold, size: 16),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Pour avoir la clé, vous devez obligatoirement activer votre Coffre',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (config.cashInFee > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '(${Formatters.formatCurrency(membershipAmount)} + ${Formatters.formatCurrency(config.cashInFee)} frais)',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
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
                          const Text('Achat du Coffre :', style: TextStyle(color: AppColors.textSecondary)),
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
                const SizedBox(height: 16),

                // Supported Mobile Money Operators Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          Icon(Icons.payment_rounded, size: 16, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Paiement & Retrait par Mobile Money',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOperatorBadge('wave', 'Wave'),
                          _buildOperatorBadge('orange', 'Orange'),
                          _buildOperatorBadge('mtn', 'MTN'),
                          _buildOperatorBadge('moov', 'Moov'),
                          _buildOperatorBadge('djamo', 'Djamo'),
                        ],
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
                  icon: Icons.vpn_key_rounded,
                  title: "La Clé d'Or d'activation",
                  subtitle: "Activez votre coffre pour recevoir votre Clé d'Or. Sans cette clé, votre coffre reste fermé et aucun retrait n'est possible.",
                ),
                _buildBenefitItem(
                  icon: Icons.auto_awesome,
                  title: 'Remplissez votre Coffre à 3 niveaux',
                  subtitle: 'Chaque ami qui active son coffre dépose de l\'or dans le vôtre : ${Formatters.formatCurrency(c1)} (Niveau 1), ${Formatters.formatCurrency(c2)} (Niveau 2), et ${Formatters.formatCurrency(c3)} (Niveau 3).',
                ),
                _buildBenefitItem(
                  icon: Icons.mobile_friendly_outlined,
                  title: 'Retraits Mobile Money instantanés',
                  subtitle: 'Retirez l\'or de votre coffre directement via Wave, Orange Money, MTN, Moov et Djamo.',
                ),
                _buildBenefitItem(
                  icon: Icons.qr_code_2_outlined,
                  title: 'Votre Clé de partage & QR Code',
                  subtitle: 'Partagez votre clé personnelle avec vos contacts en un clic pour faire grandir vos gains.',
                ),

                const SizedBox(height: 32),

                if (_checkoutUrl == null) ...[
                  CustomButton(
                    text: 'Activer le Coffre & Obtenir la Clé',
                    icon: Icons.vpn_key_rounded,
                    isLoading: _isLoading,
                    onPressed: _initiatePayment,
                  ),
                ] else ...[
                  CustomButton(
                    text: 'Payer & Débloquer la Clé',
                    icon: Icons.open_in_new,
                    isLoading: _isLoading,
                    onPressed: () => _openPayDunya(_checkoutUrl!),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: "J'ai validé le paiement",
                    icon: Icons.check_circle_outline,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.successGreen,
                    onPressed: _checkPaymentStatus,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _initiatePayment,
                      icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                      label: const Text(
                        'Générer un nouveau lien de paiement',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
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

  Widget _buildOperatorBadge(String brandKey, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OperatorBrandLogo(operatorKey: brandKey, size: 36),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
