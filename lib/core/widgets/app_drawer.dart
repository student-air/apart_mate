// lib/core/widgets/app_drawer.dart

import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/routes/app_routes.dart';
// import 'package:apart_mate/core/utils/app_snackbar.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String roleLabel;
  final String societyName;
  final String? photoPath;
  final bool isTenant; // NEW

  const AppDrawer({
    super.key,
    required this.userName,
    required this.roleLabel,
    required this.societyName,
    this.photoPath,
    this.isTenant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Avatar (left) + Logo (right) — same size, same alignment
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Avatar
    Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accentGreen,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.accentGreen,
          fontSize: 22,
        ),
      ),
    ),

    const Spacer(),

    // Logo — exact same size
    SizedBox(
      width: 56,
      height: 56,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.apartment_rounded,
          color: AppColors.accentGreen,
          size: 28,
        ),
      ),
    ),
  ],
),

                  const SizedBox(height: 14),

                  // Name (left) + Owner badge (right) — same alignment
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          userName.isEmpty ? 'User' : userName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textOnDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          border: Border.all(
                            color:
                                AppColors.accentGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          roleLabel.isEmpty ? 'Owner' : roleLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Society name
                  Text(
                    societyName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Switch to Tenant button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => AppNavigation.handleSwitchRole(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentGreen,
                        side: BorderSide(
                          color: AppColors.accentGreen.withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: Text(
  isTenant ? 'Switch to Owner' : 'Switch to Tenant',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu items ────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: <Widget>[
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onTap: () {
                      Get.back();
                      AppNavigation.goHome();
                    },
                  ),

                  if (!isTenant) ...[
                    _DrawerItem(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add Tenant',
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.addTenant);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.badge_rounded,
                      label: 'Add Manager',
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.addManager);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.groups_rounded,
                      label: 'Members',
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.members);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.home_work_rounded,
                      label: 'My Properties',
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.manageProperties);
                      },
                    ),
                  ],

                  if (isTenant) ...[
                    _DrawerItem(
                      icon: Icons.apartment_rounded,
                      label: 'My Flat',
                      onTap: () {
                        Get.back();
                        // later: flat details
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.report_problem_rounded,
                      label: 'Complaints',
                      onTap: () {
                        Get.back();
                        // later: complaints
                      },
                    ),
                  ],

                  _DrawerItem(
                    icon: Icons.campaign_rounded,
                    label: 'Updates',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.updates);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Contact Admin',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.profile);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColors.textMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}