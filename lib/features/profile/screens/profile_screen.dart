import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_converter.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../membership/screens/membership_payment_screen.dart';
import 'security_screen.dart';

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
                  Builder(
                    builder: (context) {
                      final photoBytes = ImageConverter.decodeBase64Photo(user?.photo);
                      return Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _showPhotoOptions(context, ref, user),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                                  backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                                  child: photoBytes == null
                                      ? Text(
                                          user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'K',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showPhotoOptions(context, ref, user),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showPhotoOptions(context, ref, user),
                            icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryBlue),
                            label: Text(
                              user?.photo != null && user!.photo!.isNotEmpty
                                  ? 'Modifier la photo'
                                  : 'Ajouter une photo (max 500 Ko)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SecurityScreen()),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.support_agent, color: AppColors.primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              const Text('Assistance Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Une question ou besoin d\'aide ? Notre support est à votre disposition.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 16),

                              // Email Item
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('mailto:contact@kobsontech.com?subject=Assistance%20Kobson%20Cash');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email_outlined, color: AppColors.primaryBlue, size: 20),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Email', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            Text('contact@kobsontech.com', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                                        onPressed: () {
                                          Clipboard.setData(const ClipboardData(text: 'contact@kobsontech.com'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Email copié !'), duration: Duration(seconds: 1)),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Phone Item
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('tel:+2250707186396');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, color: AppColors.primaryBlue, size: 20),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Téléphone', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            Text('+225 07 07 18 63 96', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                                        onPressed: () {
                                          Clipboard.setData(const ClipboardData(text: '+2250707186396'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Numéro copié !'), duration: Duration(seconds: 1)),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // WhatsApp Action Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse('https://wa.me/2250707186396?text=Bonjour%20Kobson%20Cash%2C%20j%27ai%20besoin%20d%27assistance.');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                                label: const Text('Discuter sur WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
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

  void _showPhotoOptions(BuildContext context, WidgetRef ref, UserModel? user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Photo de profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Conversion & compression automatique (taille max : 500 Ko)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F1FF),
                  child: Icon(Icons.photo_camera, color: AppColors.primaryBlue),
                ),
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndProcessImage(context, ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F1FF),
                  child: Icon(Icons.photo_library, color: AppColors.primaryBlue),
                ),
                title: const Text('Choisir depuis la galerie'),
                subtitle: const Text('Importer une photo de votre appareil'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndProcessImage(context, ref, ImageSource.gallery);
                },
              ),
              if (user?.photo != null && user!.photo!.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFECEC),
                    child: Icon(Icons.delete_outline, color: AppColors.errorRed),
                  ),
                  title: const Text('Supprimer la photo', style: TextStyle(color: AppColors.errorRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deletePhoto(context, ref);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndProcessImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const PopScope(
          canPop: false,
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      'Optimisation de la photo...',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Compression garantie sous 500 Ko',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final base64Photo = await ImageConverter.processAndConvertToBase64(pickedFile);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

      if (base64Photo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de traiter la photo sélectionnée.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      final success = await ref.read(authProvider.notifier).updateProfilePhoto(base64Photo);
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès (taille < 500 Ko) !'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        final error = ref.read(authProvider).error ?? 'Erreur lors de la mise à jour';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(authProvider.notifier).updateProfilePhoto('');
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil retirée.'),
        ),
      );
    }
  }
}
