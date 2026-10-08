import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/google_sign_in_button.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../dashboard/screens/main_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;
  String? _rememberedUserName;
  bool _isRememberedUser = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final lastId = await TokenStorage.getLastIdentifier();
    final lastName = await TokenStorage.getLastUserName();
    if (lastId != null && lastId.isNotEmpty && mounted) {
      setState(() {
        _identifierController.text = lastId;
        _rememberedUserName = lastName;
        _isRememberedUser = true;
      });
    }
  }

  void _switchAccount() {
    setState(() {
      _identifierController.clear();
      _passwordController.clear();
      _rememberedUserName = null;
      _isRememberedUser = false;
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _identifierController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final googleEmailController = TextEditingController();
    final googlePasswordController = TextEditingController();
    final googleFirstNameController = TextEditingController();
    final googleLastNameController = TextEditingController();
    final googleReferralController = TextEditingController();
    bool isRegisterMode = false;
    bool obscureGooglePassword = true;
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
                  Row(
                    children: [
                      const CustomPaint(
                        size: Size(26, 26),
                        painter: GoogleLogoPainter(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isRegisterMode ? 'Inscription via Google' : 'Connexion via Google',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRegisterMode
                        ? 'Créez votre compte Kobson Cash associé à Google en définissant votre mot de passe secret.'
                        : 'Accédez à votre compte Google. Votre mot de passe secret est requis pour accéder à vos fonds.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
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

                  if (isRegisterMode) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Prénom',
                            hintText: 'ex: Kouamé',
                            controller: googleFirstNameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Nom',
                            hintText: 'ex: Jean',
                            controller: googleLastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  CustomTextField(
                    label: 'Adresse Email Google',
                    hintText: 'ex: votre.compte@gmail.com',
                    controller: googleEmailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: isRegisterMode ? 'Définir un Mot de passe' : 'Mot de passe Kobson Cash',
                    hintText: '••••••••',
                    controller: googlePasswordController,
                    obscureText: obscureGooglePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureGooglePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setSheetState(() => obscureGooglePassword = !obscureGooglePassword),
                    ),
                  ),

                  if (isRegisterMode) ...[
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Code de parrainage (Optionnel)',
                      hintText: 'ex: KOB12345',
                      controller: googleReferralController,
                      prefixIcon: const Icon(Icons.card_giftcard, color: AppColors.textSecondary),
                    ),
                  ],

                  const SizedBox(height: 22),
                  CustomButton(
                    text: isRegisterMode ? 'Créer mon compte Google' : 'Déverrouiller l\'accès',
                    isLoading: _isGoogleLoading,
                    onPressed: () async {
                      final email = googleEmailController.text.trim();
                      final pass = googlePasswordController.text;
                      if (email.isEmpty) {
                        setSheetState(() => localError = 'Veuillez saisir votre email Google');
                        return;
                      }
                      if (pass.isEmpty) {
                        setSheetState(() => localError = 'Veuillez saisir votre mot de passe secret');
                        return;
                      }
                      setSheetState(() {
                        localError = null;
                        _isGoogleLoading = true;
                      });

                      final navigator = Navigator.of(context);
                      final success = await ref.read(authProvider.notifier).googleAuth(
                            email: email,
                            firstName: isRegisterMode ? googleFirstNameController.text.trim() : '',
                            lastName: isRegisterMode ? googleLastNameController.text.trim() : '',
                            password: pass,
                            referralCode: isRegisterMode ? googleReferralController.text.trim() : null,
                          );

                      if (!mounted) return;
                      setSheetState(() => _isGoogleLoading = false);

                      if (success) {
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainShell()),
                          (route) => false,
                        );
                      } else {
                        final err = ref.read(authProvider).error ?? 'Erreur lors de l\'authentification Google';
                        setSheetState(() => localError = err);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setSheetState(() {
                          isRegisterMode = !isRegisterMode;
                          localError = null;
                        });
                      },
                      child: Text(
                        isRegisterMode
                            ? 'Déjà inscrit ? Se connecter avec Google'
                            : 'Nouveau compte Google ? S\'inscrire ici',
                        style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isRememberedUser
                        ? 'Bonjour, ${_rememberedUserName ?? 'Adhérent'} !'
                        : 'Connexion',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRememberedUser
                        ? 'Veuillez saisir votre mot de passe pour déverrouiller votre coffre et accéder à vos gains.'
                        : 'Bienvenue sur Kobson Cash. Accédez à votre compte pour gérer vos gains.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

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
                    const SizedBox(height: 20),
                  ],

                  CustomTextField(
                    label: 'Email ou Numéro de téléphone',
                    hintText: 'ex: kouame@gmail.com ou 0701020304',
                    controller: _identifierController,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Veuillez saisir votre email ou téléphone';
                      }
                      return null;
                    },
                  ),
                  if (_isRememberedUser) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _switchAccount,
                        child: const Text(
                          'Changer de compte ?',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Mot de passe',
                    hintText: '••••••••',
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
                      if (v == null || v.isEmpty) {
                        return 'Veuillez saisir votre mot de passe';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  CustomButton(
                    text: _isRememberedUser ? 'Déverrouiller l\'accès' : 'Se connecter',
                    isLoading: authState.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GoogleSignInButton(
                    isLoading: _isGoogleLoading,
                    onPressed: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous n'avez pas de compte ? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "S'inscrire",
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
