import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

/// Compact icon + label pill, meant to sit side-by-side with another
/// (e.g. Google | Apple), unlike AppSecondaryButton which is full-width.
class AppSocialPillButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const AppSocialPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderColor = const Color(0xFFE5E7EB),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelLarge.copyWith(color: foregroundColor)),
          ],
        ),
      ),
    );
  }
}
