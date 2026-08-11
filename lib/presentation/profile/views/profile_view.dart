// lib/presentation/profile/views/profile_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
//import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background,
      // bottomNavigationBar: AppBottomNav(
      //   activeTab: AppNavTab.profile,
      //   onHome: () => Get.offNamed(AppRoutes.dashboard),
      //   onUpdates: () {},
      //   onRequests: () {},
      //   onProfile: () {},
      // ),
      body: Obx(() {
        if (controller.isLoading.value || controller.user.value == null) {
          return const AppLoading();
        }

        final user = controller.user.value!;
        final profile = controller.profile.value;
        final society = controller.society.value;

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(user: user, roleLabel: controller.roleLabel),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.space20,
                    AppDimens.space20,
                    AppDimens.space20,
                    AppDimens.space24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (society != null) ...[
                        Text('SOCIETY', style: AppTextStyles.overline),
                        const SizedBox(height: AppDimens.space10),
                        _SocietyCard(society: society),
                        const SizedBox(height: AppDimens.space20),
                      ],
                      Text('PERSONAL INFORMATION', style: AppTextStyles.overline),
                      const SizedBox(height: AppDimens.space10),
                      _InfoCard(user: user, profile: profile),
                      const SizedBox(height: AppDimens.space20),
                      Text('SETTINGS', style: AppTextStyles.overline),
                      const SizedBox(height: AppDimens.space10),
                      _MenuList(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final dynamic user; // UserModel
  final String roleLabel;
  const _Header({required this.user, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    final photoPath = user.photoPath as String?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space28,
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark)),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: const Icon(Icons.settings_outlined, color: AppColors.textOnDark, size: 22),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space20),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.pastelGreenBg,
                shape: BoxShape.circle,
                image: (photoPath != null && photoPath.isNotEmpty)
                    ? DecorationImage(image: FileImage(File(photoPath)), fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: (photoPath == null || photoPath.isEmpty)
                  ? Text(
                      (user.initials as String),
                      style: AppTextStyles.h1.copyWith(color: AppColors.pastelGreenIcon, fontSize: 30),
                    )
                  : null,
            ),
            const SizedBox(height: AppDimens.space12),
            Text(user.fullName as String, style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark)),
            const SizedBox(height: 4),
            Text(user.email as String, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnDarkMuted)),
            if (roleLabel.isNotEmpty) ...[
              const SizedBox(height: AppDimens.space10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(roleLabel, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SocietyCard extends StatelessWidget {
  final dynamic society; // SocietyModel
  const _SocietyCard({required this.society});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.pastelGreenBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.apartment_rounded, size: 24, color: AppColors.pastelGreenIcon),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(society.name as String, style: AppTextStyles.h4),
                Text(
                  '${society.address}, ${society.city}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (society.isVerified as bool)
            const Icon(Icons.verified_rounded, size: 18, color: AppColors.accentGreenDark),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic user; // UserModel
  final dynamic profile; // ProfileModel?
  const _InfoCard({required this.user, required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.call_rounded, 'Phone', (user.phone as String).isEmpty ? '—' : user.phone as String),
      if (profile != null) ...[
        (Icons.wc_rounded, 'Gender', (profile.gender as String).isEmpty ? '—' : profile.gender as String),
        (Icons.location_city_rounded, 'City', (profile.city as String).isEmpty ? '—' : profile.city as String),
        (Icons.work_outline_rounded, 'Occupation', (profile.occupation as String).isEmpty ? '—' : profile.occupation as String),
        (
          Icons.emergency_rounded,
          'Emergency Contact',
          (profile.emergencyContact as String).isEmpty ? '—' : profile.emergencyContact as String,
        ),
      ],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final (icon, label, value) = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: AppColors.textSecondary),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final ProfileController controller;
  const _MenuList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            onTap: controller.goToEditProfile,
          ),
          _MenuTile(icon: Icons.description_outlined, label: 'Documents', onTap: () {}),
          _MenuTile(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () {}),
          _MenuTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            isDestructive: true,
            isLast: true,
            onTap: controller.confirmLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppDimens.space12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color))),
            if (!isDestructive) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}