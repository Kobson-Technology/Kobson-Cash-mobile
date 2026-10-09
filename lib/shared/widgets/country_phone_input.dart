import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CountryDialCode {
  final String code; // "+225"
  final String flag; // "🇨🇮"
  final String iso;  // "CI"
  final String name; // "Côte d'Ivoire"

  const CountryDialCode({
    required this.code,
    required this.flag,
    required this.iso,
    required this.name,
  });

  String get shortLabel => '$flag $code ($iso)';
}

const List<CountryDialCode> kSupportedCountries = [
  CountryDialCode(code: '+225', flag: '🇨🇮', iso: 'CI', name: "Côte d'Ivoire"),
  CountryDialCode(code: '+221', flag: '🇸🇳', iso: 'SN', name: 'Sénégal'),
  CountryDialCode(code: '+226', flag: '🇧🇫', iso: 'BF', name: 'Burkina Faso'),
  CountryDialCode(code: '+223', flag: '🇲🇱', iso: 'ML', name: 'Mali'),
  CountryDialCode(code: '+228', flag: '🇹🇬', iso: 'TG', name: 'Togo'),
  CountryDialCode(code: '+229', flag: '🇧🇯', iso: 'BJ', name: 'Bénin'),
  CountryDialCode(code: '+227', flag: '🇳🇪', iso: 'NE', name: 'Niger'),
  CountryDialCode(code: '+224', flag: '🇬🇳', iso: 'GN', name: 'Guinée'),
];

class CountryPhoneInput extends StatelessWidget {
  final CountryDialCode selectedCountry;
  final ValueChanged<CountryDialCode> onCountryChanged;
  final TextEditingController phoneController;
  final String? Function(String?)? validator;

  const CountryPhoneInput({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.phoneController,
    this.validator,
  });

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.public, color: AppColors.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Sélectionnez votre indicatif pays',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kSupportedCountries.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
                  itemBuilder: (context, index) {
                    final item = kSupportedCountries[index];
                    final isSelected = item.code == selectedCountry.code && item.iso == selectedCountry.iso;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.flag, style: const TextStyle(fontSize: 22)),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${item.code} (${item.iso})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20)
                          : null,
                      onTap: () {
                        onCountryChanged(item);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro de Téléphone (Mobile Money) *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton sélecteur d'indicatif (ex: 🇨🇮 +225 (CI) v)
            InkWell(
              onTap: () => _showCountryPicker(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCountry.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${selectedCountry.code} (${selectedCountry.iso})',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Champ de saisie du numéro
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintText: '07 00 00 00 00',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                validator: validator ??
                    (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Veuillez saisir votre numéro Mobile Money';
                      }
                      final digits = v.replaceAll(RegExp(r'\s+'), '');
                      if (digits.length < 8) {
                        return 'Numéro incomplet (min. 8 chiffres)';
                      }
                      return null;
                    },
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Ce numéro servira à vous connecter et à recevoir vos retraits Mobile Money.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
