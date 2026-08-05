import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

/// Shows a styled delete-confirmation dialog — big rounded card, bold
/// title, description, a solid red confirm button with icon, and a plain
/// Cancel text link below it.
Future<void> showAppDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.surfaceMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radius2xl)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Text(message, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(confirmLabel, style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}