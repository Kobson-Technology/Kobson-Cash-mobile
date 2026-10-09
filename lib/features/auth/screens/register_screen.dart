import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/country_phone_input.dart';
import '../../../shared/widgets/google_sign_in_button.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/screens/main_shell.dart';
import 'login_screen.dart';

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

  int _currentStep = 0; // 0 = Seul Google apparaît, 1 = Formulaire à remplir
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;
  final bool _isGoogleSelecting = false;
  CountryDialCode _selectedCountry = kSupportedCountries[0];

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

  Future<void> _handleGoogleSelection() async {
    final googleEmailCtrl = TextEditingController(text: _emailController.text);
    final googleFirstNameCtrl = TextEditingController(text: _firstNameController.text.isNotEmpty ? _firstNameController.text : 'Kouamé');
    final googleLastNameCtrl = TextEditingController(text: _lastNameController.text.isNotEmpty ? _lastNameController.text : 'Konan');
    String? localError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      CustomPaint(
                        size: Size(26, 26),
                        painter: GoogleLogoPainter(),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Connexion avec Google',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sélectionnez votre compte Google pour initialiser votre inscription en toute sécurité.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 18),

                  if (localError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(localError!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Prénom',
                          hintText: 'ex: Kouamé',
                          controller: googleFirstNameCtrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Nom',
                          hintText: 'ex: Konan',
                          controller: googleLastNameCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Adresse Email Google',
                    hintText: 'ex: votre.compte@gmail.com',
                    controller: googleEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 22),

                  CustomButton(
                    text: 'Continuer avec ce compte',
                    isLoading: _isGoogleSelecting,
                    onPressed: () {
                      final email = googleEmailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
                        setSheetState(() => localError = 'Veuillez saisir une adresse email Google valide');
                        return;
                      }

                      setState(() {
                        _emailController.text = email;
                        _firstNameController.text = googleFirstNameCtrl.text.trim();
                        _lastNameController.text = googleLastNameCtrl.text.trim();
                        _currentStep = 1; // Passage au formulaire complet
                      });

                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    final refCode = _referralCodeController.text.trim();
    if (refCode.isEmpty) {
      final confirmNoSponsor = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.help_outline_rounded, color: AppColors.accentGold, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Avez-vous un parrain ?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Vous n\'avez pas renseigné de clef du parrain.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                'Si une personne vous a invité(e) sur Kobson Cash, demandez-lui sa clef de parrain pour rejoindre son équipe.\n\n⚠️ Attention : vous ne pourrez plus ajouter de parrain après la création de votre compte.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Saisir une clef', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Continuer sans parrain'),
            ),
          ],
        ),
      );

      if (confirmNoSponsor != true) {
        return;
      }
    }

    final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final formattedPhone = rawPhone.startsWith('+')
        ? rawPhone
        : '${_selectedCountry.code}${rawPhone.replaceFirst(RegExp(r'^0+'), '')}';

    final success = await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text.trim().isEmpty ? 'Adhérent' : _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty ? 'Google' : _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: formattedPhone,
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
        title: Text(_currentStep == 0 ? 'Créer un compte' : 'Finaliser l\'inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 0),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _currentStep == 0
              ? _buildGoogleFirstStep()
              : _buildFormCompletionStep(authState),
        ),
      ),
    );
  }

  /// Étape 1 : SEUL Google apparaît pour lancer l'inscription
  Widget _buildGoogleFirstStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/images/logo.png',
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_wallet,
                size: 46,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Rejoignez Kobson Cash',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'L\'inscription commence automatiquement avec votre compte Google pour sécuriser vos gains et votre coffre d\'affiliation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 36),

        // Carte d'avantages
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildFeatureItem(Icons.verified_user_outlined, 'Authentification Google sécurisée', 'Votre identité est vérifiée instantanément.'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)),
              ),
              _buildFeatureItem(Icons.savings_outlined, 'Coffre d\'affiliation & Gains FCFA', '3 niveaux de commissions versées en direct.'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)),
              ),
              _buildFeatureItem(Icons.phone_android_outlined, 'Retraits Mobile Money', 'Transferts vers Wave, Orange, MTN et Moov.'),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Seul Google apparaît pour continuer
        GoogleSignInButton(
          text: 'S\'inscrire avec Google',
          isLoading: _isGoogleSelecting,
          onPressed: _handleGoogleSelection,
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Déjà un compte ? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "Se connecter",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Étape 2 : Le formulaire complet à remplir une fois Google sélectionné
  Widget _buildFormCompletionStep(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge du compte Google associé
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const CustomPaint(
                  size: Size(24, 24),
                  painter: GoogleLogoPainter(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_firstNameController.text} ${_lastNameController.text}'.trim(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                        ],
                      ),
                      Text(
                        _emailController.text,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text('Changer', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Informations complémentaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Renseignez votre numéro Mobile Money pour recevoir vos paiements et créez votre mot de passe secret.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

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

          CountryPhoneInput(
            selectedCountry: _selectedCountry,
            onCountryChanged: (c) => setState(() => _selectedCountry = c),
            phoneController: _phoneController,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'La clef du parrain',
            hintText: 'ex: KC-7X8Y9Z (Optionnel)',
            controller: _referralCodeController,
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.accentGold),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Mot de passe secret',
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
            label: 'Confirmer le mot de passe secret',
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
            text: 'Créer mon compte Kobson Cash',
            isLoading: authState.isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
