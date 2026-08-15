// lib/presentation/profile/views/profile_view.dart

import 'dart:io';
import 'package:apart_mate/core/widgets/send_complaint_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
// import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      floatingActionButton: AppAddFab(onPressed: () => SendComplaintSheet.open(),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            icon: AppNavigation.isTenant
                ? Icons.report_problem_rounded
                : Icons.groups_rounded,
            label: AppNavigation.isTenant ? 'Complaints' : 'Members',
            isActive: false,
            onTap: () {
              if (AppNavigation.isTenant) {
                // Get.toNamed(AppRoutes.complaints);
              } else {
                Get.toNamed(AppRoutes.members);
              }
            },
          ),
          NavItemData(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.user.value == null) {
          return const AppLoading();
        }

        final user = controller.user.value!;
        final society = controller.society.value;

        // Rebuild role badge when session role changes
        if (Get.isRegistered<AppSession>()) {
          Get.find<AppSession>().currentRole.value;
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 6,
                        bottom: 62,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.villa_rounded,
                                color: AppColors.accentGreen,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'My Profile',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
                      child: _IdentityCard(
                        user: user,
                        roleLabel: controller.roleLabel,
                        onEdit: controller.goToEditProfile,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ContactCard(user: user),
                ),

                if (society != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SocietyCard(society: society),
                  ),
                ],

                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SETTINGS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsCard(isTenant: controller.isTenant),
                ),

                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LogoutCard(onTap: controller.confirmLogout),
                ),

                const SizedBox(height: 20),
                Text(
                  'Apart Mate v1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// IDENTITY CARD
// ─────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserModel user;
  final String roleLabel;
  final VoidCallback onEdit;

  const _IdentityCard({
    required this.user,
    required this.roleLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final photoPath = user.photoPath;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    image: (photoPath != null && photoPath.isNotEmpty)
                        ? DecorationImage(
                            image: FileImage(File(photoPath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (photoPath == null || photoPath.isEmpty)
                      ? Text(
                          user.initials,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.accentGreen,
                            fontSize: 28,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3.copyWith(fontSize: 20),
                ),
                if (roleLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleLabel.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentGreenDark,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTACT
// ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final UserModel user;
  const _ContactCard({required this.user});

  void _copy(String label, String value) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    AppSnackbar.success('Copied', '$label copied');
  }

  @override
  Widget build(BuildContext context) {
    final phone = user.phone.isEmpty ? '—' : user.phone;
    final email = user.email.isEmpty ? '—' : user.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTACT INFORMATION',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.phone_rounded,
            title: 'Phone Number',
            value: phone,
            onCopy: () => _copy('Phone', user.phone),
          ),
          _ContactRow(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: email,
            onCopy: () => _copy('Email', user.email),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;
  final bool isLast;

  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 8 : 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F2F5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SOCIETY
// ─────────────────────────────────────────────────────────────
class _SocietyCard extends StatelessWidget {
  final SocietyModel society;
  const _SocietyCard({required this.society});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOCIETY ASSIGNMENT',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      society.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${society.address}, ${society.city}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final bool isTenant;
  const _SettingsCard({required this.isTenant});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, Color, Color, String)>[
      if (!isTenant)
        (
          Icons.home_work_rounded,
          const Color(0xFFE8F8EF),
          AppColors.accentGreenDark,
          'My Properties',
        ),
      if (isTenant)
        (
          Icons.apartment_rounded,
          const Color(0xFFE8F8EF),
          AppColors.accentGreenDark,
          'My Flat',
        ),
      (
        Icons.notifications_none_rounded,
        const Color(0xFFE8F1FF),
        const Color(0xFF3B82F6),
        'Notification Preferences',
      ),
      (
        Icons.shield_outlined,
        const Color(0xFFFFE8EC),
        const Color(0xFFEF4444),
        'Privacy & Security',
      ),
      (
        Icons.help_outline_rounded,
        const Color(0xFFE8F8EF),
        AppColors.accentGreenDark,
        'Help & Support',
      ),
      (
        Icons.description_outlined,
        const Color(0xFFF0F2F5),
        AppColors.textSecondary,
        'Terms of Service',
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, bg, fg, label) = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (label == 'My Properties') {
                    Get.toNamed(AppRoutes.manageProperties);
                  }
                },
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(20) : Radius.zero,
                  bottom: isLast ? const Radius.circular(20) : Radius.zero,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 20, color: fg),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 68,
                  color: AppColors.borderLight,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOG OUT
// ─────────────────────────────────────────────────────────────
class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEBEE),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Out',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign out of your ApartMate account',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.danger.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}