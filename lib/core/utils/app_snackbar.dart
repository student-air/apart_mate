import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

/// Centralized, high-contrast notification helper. Always use this instead
/// of calling Get.snackbar() directly, so every message in the app looks
/// consistent and stays readable regardless of what's behind it.
class AppSnackbar {
  AppSnackbar._();

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.surface,
      colorText: AppColors.textPrimary,
      titleText: Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.danger)),
      messageText: Text(message, style: AppTextStyles.bodyMedium),
      icon: const Icon(Icons.error_outline_rounded, color: AppColors.danger),
      margin: const EdgeInsets.all(AppDimens.space16),
      borderRadius: AppDimens.radiusLg,
      duration: const Duration(seconds: 3),
      boxShadows: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
    );
  }

  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.surface,
      colorText: AppColors.textPrimary,
      titleText: Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.successGreenDark)),
      messageText: Text(message, style: AppTextStyles.bodyMedium),
      icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.successGreen),
      margin: const EdgeInsets.all(AppDimens.space16),
      borderRadius: AppDimens.radiusLg,
      duration: const Duration(seconds: 2),
      boxShadows: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
    );
  }

static void info(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.surface,
      colorText: AppColors.textPrimary,
      titleText: Text(title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
      messageText: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.accentGreenDark),
      margin: const EdgeInsets.all(AppDimens.space16),
      borderRadius: AppDimens.radiusLg,
      duration: const Duration(seconds: 3),
      boxShadows: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
    );
  }

  static void show(String feature, String s, {required SnackPosition snackPosition, required EdgeInsets margin, required int borderRadius, required Duration duration}) {}
}