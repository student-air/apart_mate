import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

/// Primary pill-shaped CTA button — dark fill, green or white label,
/// matching every "Login / Submit / Save" button in the design.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primaryDark,
    this.foregroundColor = AppColors.accentGreen,
    this.icon,
    this.height = AppDimens.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: foregroundColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppDimens.space8),
                  ],
                  Text(label, style: AppTextStyles.buttonLarge.copyWith(color: foregroundColor)),
                ],
              ),
      ),
    );
  }
}

/// Secondary outline pill button (e.g. "Continue with Google", "Cancel").
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final double height;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.borderColor = AppColors.border,
    this.foregroundColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.surface,
    this.height = AppDimens.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: AppDimens.space12)],
            Text(label, style: AppTextStyles.buttonMedium.copyWith(color: foregroundColor)),
          ],
        ),
      ),
    );
  }
}
