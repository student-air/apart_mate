// lib/presentation/members/views/members_view.dart

import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/send_complaint_sheet.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/presentation/members/controllers/members_controller.dart';

class MembersView extends GetView<MembersController> {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: AppColors.background,
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  floatingActionButton: AppAddFab(
    onPressed: () => SendComplaintSheet.open(),
  ),
  bottomNavigationBar: AppBottomNav(
    items: [
      NavItemData(
        icon: Icons.home_rounded,
        label: 'Home',
        isActive: false,
        onTap: AppNavigation.goHome,
      ),
      NavItemData(
        icon: Icons.campaign_rounded,
        label: 'Updates',
        isActive: false,
        onTap: () => Get.toNamed(AppRoutes.updates),
      ),
      NavItemData(
        icon: Icons.groups_rounded,
        label: 'Members',
        isActive: true,
        onTap: () {},
      ),
      NavItemData(
        icon: Icons.person_rounded,
        label: 'Profile',
        isActive: false,
        onTap: () => Get.toNamed(AppRoutes.profile),
      ),
    ],
  ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                children: [
                  GestureDetector(
                    // IMPORTANT: do NOT use Get.back()
                    // that returns to Add Tenant + invite sheet
                    onTap: AppNavigation.goHome,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            AppColors.textOnDark.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textOnDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Members',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.villa_rounded,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _TabChip(
                      label: 'Tenants',
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () => controller.switchTab(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TabChip(
                      label: 'Managers',
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () => controller.switchTab(1),
                    ),
                  ),
                ],
              );
            }),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.selectedTab.value == 1) {
                return Center(
                  child: Text(
                    'No managers yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }

              final list = controller.tenants;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No tenants yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final t = list[i];
                  return Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDimens.radius2xl),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.pastelGreenBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.accentGreenDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.fullName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.propertyLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pastelOrangeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.status.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.pastelOrangeIcon,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete
          IconButton(
            onPressed: () => controller.deleteTenant(t),
            icon: const Icon(Icons.delete_rounded),
            color: AppColors.danger,
            tooltip: 'Remove',
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Divider(height: 1, color: AppColors.borderLight),
      const SizedBox(height: 12),
      // Invite code row + copy
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.vpn_key_rounded, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.inviteCode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.copyCode(t.inviteCode),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreenDark,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelGreenBg : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected
                ? AppColors.successGreenDark
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}