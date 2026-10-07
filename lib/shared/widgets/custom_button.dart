import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: foregroundColor ?? AppTheme.primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor ?? AppTheme.primaryBlue),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: foregroundColor ?? AppTheme.primaryBlue, size: 20), const SizedBox(width: 8)],
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: foregroundColor ?? AppTheme.primaryBlue),
                  ),
                ],
              ),
      );
    }

    final bg = backgroundColor ?? AppTheme.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: foregroundColor ?? Colors.white, size: 20), const SizedBox(width: 8)],
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: foregroundColor ?? Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
