// lib/presentation/role_selection/views/role_selection_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/presentation/role_selection/controllers/role_selection_controller.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'owner':
        return Icons.workspace_premium_rounded;
      case 'tenant':
        return Icons.key_rounded;
      case 'employee':
        return Icons.badge_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  (Color bg, Color icon) _colorsFor(String key, bool isSelected) {
    switch (key) {
      case 'owner':
        return isSelected
            ? (AppColors.warning, AppColors.primaryDark)
            : (AppColors.warningBg, AppColors.warning);
      case 'tenant':
        return isSelected
            ? (AppColors.pastelBlueIcon, AppColors.surface)
            : (AppColors.pastelBlueBg, AppColors.pastelBlueIcon);
      case 'employee':
        return isSelected
            ? (AppColors.accentGreen, AppColors.primaryDark)
            : (AppColors.pastelGreenBg, AppColors.pastelGreenIcon);
      default:
        return (AppColors.surfaceMuted, AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space28,
                AppDimens.space20,
                AppDimens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final role in RoleSelectionController.roles) ...[
                    Obx(() {
                      final isSelected = controller.selectedRole.value == role.value;
                      final colors = _colorsFor(role.value, isSelected);
                      return _RoleCard(
                        role: role,
                        icon: _iconFor(role.value),
                        isSelected: isSelected,
                        bgColor: colors.$1,
                        iconColor: colors.$2,
                        onTap: () => controller.selectRole(role.value),
                      );
                    }),
                    const SizedBox(height: AppDimens.space20),
                  ],
                ],
              ),
            ),
          ),
          _Footer(controller: controller),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final RoleSelectionController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.headerRadius),
          bottomRight: Radius.circular(AppDimens.headerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.goBack,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: const Padding(
                padding: EdgeInsets.only(top: 4, right: 12),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark, size: 22),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Your Role',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'How will you use apart_mate?',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnDarkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            const _LogoBadge(),
          ],
        ),
      ),
    );
  }
}

/// Fixed-size logo tile with a fallback icon if the asset fails to load.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.apartment_rounded, size: 20, color: AppColors.primaryDark),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleOption role;
  final IconData icon;
  final bool isSelected;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.isSelected,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius2xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppDimens.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius2xl),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(width: AppDimens.space20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.title, style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.accentGreen : AppColors.border,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned footer so "Continue" always sits at the very bottom of the
/// screen, independent of how many role cards are above it — unlike
/// putting the button inside the scroll view, this never moves as
/// content grows.
class _Footer extends StatelessWidget {
  final RoleSelectionController controller;
  const _Footer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => AppPrimaryButton(
            label: 'Continue',
            isLoading: controller.isLoading.value,
            onPressed: controller.continueWithRole,
          ),
        ),
      ),
    );
  }
}