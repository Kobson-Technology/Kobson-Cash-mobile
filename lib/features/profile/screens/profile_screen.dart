import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../membership/screens/membership_payment_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(24),
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
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'K',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Membre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: user?.hasActiveMembership == true
                          ? AppColors.successGreen.withValues(alpha: 0.1)
                          : AppColors.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.hasActiveMembership == true ? 'Adhésion Active' : 'Adhésion Non Activée',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: user?.hasActiveMembership == true
                            ? AppColors.successGreen
                            : AppColors.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Info List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppColors.primaryBlue),
                    title: const Text('Téléphone', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    subtitle: Text(user?.phoneNumber ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_outlined, color: AppColors.accentGold),
                    title: const Text('Code de parrainage personnel', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    subtitle: Text(user?.referralCode ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 20, color: AppColors.primaryBlue),
                      onPressed: () {
                        if (user?.referralCode != null) {
                          Clipboard.setData(ClipboardData(text: user!.referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code de parrainage copié !')),
                          );
                        }
                      },
                    ),
                  ),
                  if (user?.hasActiveMembership == false) ...[
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.star_outline, color: AppColors.accentGold),
                      title: const Text('Activer mon adhésion', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                      subtitle: const Text('Accédez aux commissions & retraits', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MembershipPaymentScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Actions
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security_outlined, color: AppColors.navyBlue),
                    title: const Text('Sécurité & Mot de passe'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité disponible dans le prochain déploiement.')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.support_agent_outlined, color: AppColors.navyBlue),
                    title: const Text('Assistance Kobson Cash'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Assistance'),
                          content: const Text(
                            'Support Kobson Cash Côte d\'Ivoire\nEmail: contact@kobsoncash.com\nTél: +225 07 00 00 00 00',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.errorRed),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Déconnexion', style: TextStyle(color: AppColors.errorRed))),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
