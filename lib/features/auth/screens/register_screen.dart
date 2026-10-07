import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/screens/main_shell.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? initialReferralCode;

  const RegisterScreen({super.key, this.initialReferralCode});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final TextEditingController _referralCodeController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  @override
  void initState() {
    super.initState();
    _referralCodeController = TextEditingController(text: widget.initialReferralCode ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions générales.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          referralCode: _referralCodeController.text.trim().isEmpty ? null : _referralCodeController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rejoignez Kobson Cash',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complétez vos informations pour démarrer votre réseau d’affiliation.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Prénom',
                        hintText: 'Kouamé',
                        controller: _firstNameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Nom',
                        hintText: 'Konan',
                        controller: _lastNameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Adresse Email',
                  hintText: 'kouame.konan@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Veuillez renseigner votre email';
                    if (!v.contains('@') || !v.contains('.')) return 'Adresse email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Numéro de téléphone (Côte d\'Ivoire)',
                  hintText: 'ex: 0701020304 ou +2250701020304',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Veuillez saisir votre numéro';
                    if (v.trim().length < 8) return 'Numéro trop court';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Code de parrainage (Optionnel)',
                  hintText: 'ex: KC-7X8Y9Z',
                  controller: _referralCodeController,
                  prefixIcon: const Icon(Icons.card_giftcard_outlined, color: AppColors.accentGold),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Mot de passe',
                  hintText: '•••••••• (min. 8 caractères)',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Minimum 8 caractères requis';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Confirmer le mot de passe',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        "J'accepte les conditions d'utilisation et la politique de confidentialité de Kobson Cash.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Créer mon compte',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
