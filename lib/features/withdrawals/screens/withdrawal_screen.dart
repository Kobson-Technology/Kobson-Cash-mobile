import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/config_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../models/withdrawal_models.dart';
import '../providers/withdrawal_provider.dart';
import 'withdrawal_history_screen.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  WithdrawalOperator _selectedOperator = WithdrawalOperator.wave;
  double _requestedAmount = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null && user.phoneNumber.isNotEmpty) {
      _phoneController.text = user.phoneNumber;
    }

    _amountController.addListener(() {
      final val = double.tryParse(_amountController.text.trim()) ?? 0.0;
      setState(() {
        _requestedAmount = val;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmWithdrawal(PublicConfig config, double availableBalance) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final fee = config.calculateWithdrawalFee(amount);
    final net = config.calculateNetWithdrawal(amount);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer le retrait', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montant débité: ${Formatters.formatCurrency(amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (fee > 0)
              Text(
                'Frais opérateur (${config.withdrawalFeePercent.toStringAsFixed(config.withdrawalFeePercent.truncateToDouble() == config.withdrawalFeePercent ? 0 : 1)}%): ${Formatters.formatCurrency(fee)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            Text(
              'Net versé sur votre compte: ${Formatters.formatCurrency(net)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen),
            ),
            const SizedBox(height: 12),
            Text('Opérateur: ${_selectedOperator.displayName}'),
            Text('Numéro: ${_phoneController.text.trim()}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Note: Ces fonds seront immédiatement placés en réserve (HOLD) jusqu\'à la validation du déboursement.',
                style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      final res = await ref.read(withdrawalNotifierProvider.notifier).submitWithdrawal(
            amount: amount,
            operator: _selectedOperator,
            phoneNumber: _phoneController.text.trim(),
          );

      if (mounted && res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande de retrait de ${Formatters.formatCurrency(amount)} initiée avec succès !'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WithdrawalHistoryScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final configAsync = ref.watch(configProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Retirer des fonds'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WithdrawalHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (config) {
          return walletAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erreur: $err')),
            data: (wallet) {
              final available = wallet.availableBalance;
              final fee = config.calculateWithdrawalFee(_requestedAmount);
              final net = config.calculateNetWithdrawal(_requestedAmount);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balance Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.navyBlue, Color(0xFF1E3A8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Solde disponible pour retrait',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatCurrency(available),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (wallet.heldBalance > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                '(${Formatters.formatCurrency(wallet.heldBalance)} réservés en cours de traitement)',
                                style: const TextStyle(color: AppColors.accentGold, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Select Operator
                      const Text(
                        'Choisissez le moyen de déboursement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: WithdrawalOperator.values.map((op) {
                          final isSelected = _selectedOperator == op;
                          return ChoiceChip(
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedOperator = op);
                            },
                            avatar: Icon(
                              Icons.payment,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.primaryBlue,
                            ),
                            label: Text(op.displayName),
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Phone Number
                      CustomTextField(
                        label: 'Numéro de réception',
                        hintText: 'ex: 0701020304',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_android, color: AppColors.textSecondary),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Numéro requis pour le transfert';
                          if (v.trim().length < 8) return 'Numéro trop court';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Amount Field
                      CustomTextField(
                        label: 'Montant à retirer (FCFA)',
                        hintText: 'Min. ${Formatters.formatCurrency(config.minimumWithdrawal)}',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money, color: AppColors.textSecondary),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Veuillez saisir un montant';
                          final numVal = double.tryParse(v.trim());
                          if (numVal == null) return 'Montant invalide';
                          if (numVal < config.minimumWithdrawal) {
                            return 'Minimum de retrait: ${Formatters.formatCurrency(config.minimumWithdrawal)}';
                          }
                          if (numVal > config.maximumWithdrawal) {
                            return 'Maximum de retrait: ${Formatters.formatCurrency(config.maximumWithdrawal)}';
                          }
                          if (numVal > available) {
                            return 'Solde disponible insuffisant';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Net Calculation Preview Box
                      if (_requestedAmount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Montant débité :', style: TextStyle(color: AppColors.textSecondary)),
                                  Text(Formatters.formatCurrency(_requestedAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Frais opérateur (${config.withdrawalFeePercent.toStringAsFixed(config.withdrawalFeePercent.truncateToDouble() == config.withdrawalFeePercent ? 0 : 1)}%) :',
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                  Text(Formatters.formatCurrency(fee), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Net à recevoir sur votre compte :',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(net),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Les frais de déboursement Mobile Money sont imputés au montant retiré. Kobson Cash applique une politique de zéro dette.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.2),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 28),

                      CustomButton(
                        text: 'Confirmer la demande de retrait',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: () => _handleConfirmWithdrawal(config, available),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
