import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? hintText;
  final dynamic prefixIcon; // Can be IconData or Widget
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    Widget? resolvedPrefix;
    if (prefixIcon is IconData) {
      resolvedPrefix = Icon(prefixIcon as IconData, color: const Color(0xFF64748B));
    } else if (prefixIcon is Widget) {
      resolvedPrefix = prefixIcon as Widget;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? hint,
        prefixIcon: resolvedPrefix,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
