// lib/presentation/profile/views/profile_view.dart

import 'dart:io';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
// import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/core/widgets/send_complaint_sheet.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AppAddFab(
        onPressed: () => SendComplaintSheet.open(),
      ),
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
                Get.toNamed(AppRoutes.complaint);
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

        if (Get.isRegistered<AppSession>()) {
          Get.find<AppSession>().currentRole.value;
        }

        final showOwner =
            controller.isTenant && controller.hasOwnerInfo.value;
        final ownerName = controller.ownerName.value;
        final ownerPhone = controller.ownerPhone.value;
        final ownerEmail = controller.ownerEmail.value;

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
                          const SizedBox(height: AppDimens.space12),
                          Text(
                            'My Profile',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textOnDark,
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

                const SizedBox(height: AppDimens.space16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space20,
                  ),
                  child: _ContactCard(user: user),
                ),

                if (society != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space20,
                    ),
                    child: _SocietyCard(
                      society: society,
                      onPhone: controller.openPhone,
                      onEmail: controller.openEmail,
                    ),
                  ),
                ],

                if (showOwner) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space20,
                    ),
                    child: _OwnerCard(
                      name: ownerName,
                      phone: ownerPhone,
                      email: ownerEmail,
                      onPhone: controller.openPhone,
                      onEmail: controller.openEmail,
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space20,
                  ),
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
                const SizedBox(height: AppDimens.space10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space20,
                  ),
                  child: _SettingsCard(isTenant: controller.isTenant),
                ),

                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space20,
                  ),
                  child: _LogoutCard(onTap: controller.confirmLogout),
                ),

                const SizedBox(height: AppDimens.space20),
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
                      color: AppColors.pastelGreenBg,
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
                  color: AppColors.surfaceMuted,
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

  @override
  Widget build(BuildContext context) {
    final phone = user.phone.isEmpty ? '—' : user.phone;
    final email = user.email.isEmpty ? '—' : user.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          ),
          _ContactRow(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: email,
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
  final bool isLast;

  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
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
              color: AppColors.surfaceMuted,
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SOCIETY (expandable) — phone → dialer, email → mail
// NO join code
// ─────────────────────────────────────────────────────────────
class _SocietyCard extends StatefulWidget {
  final SocietyModel society;
  final void Function(String phone) onPhone;
  final void Function(String email) onEmail;

  const _SocietyCard({
    required this.society,
    required this.onPhone,
    required this.onEmail,
  });

  @override
  State<_SocietyCard> createState() => _SocietyCardState();
}

class _SocietyCardState extends State<_SocietyCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.society;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
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

          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 20,
                    color: AppColors.pastelBlueIcon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expanded
                            ? 'Tap to collapse'
                            : (s.city.isEmpty
                                ? 'Tap for society details'
                                : s.city),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (s.isVerified)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.accentGreenDark,
                    ),
                  ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  _SocietyActionRow(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: s.phone.isEmpty ? '—' : s.phone,
                    actionIcon: Icons.call_rounded,
                    onTap: s.phone.trim().isEmpty
                        ? null
                        : () => widget.onPhone(s.phone),
                  ),
                  const SizedBox(height: 10),
                  _SocietyActionRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: s.email.isEmpty ? '—' : s.email,
                    actionIcon: Icons.mail_outline_rounded,
                    onTap: s.email.trim().isEmpty
                        ? null
                        : () => widget.onEmail(s.email),
                  ),
                  const SizedBox(height: 10),
                  _SocietyActionRow(
                    icon: Icons.place_outlined,
                    label: 'Full address',
                    value: s.fullAddress,
                  ),
                  // join code intentionally omitted
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _SocietyActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData? actionIcon;
  final VoidCallback? onTap;

  const _SocietyActionRow({
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;

    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tappable
                            ? AppColors.accentGreenDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (tappable && actionIcon != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    actionIcon,
                    size: 16,
                    color: AppColors.pastelGreenIcon,
                  ),
                ),
            ],
          ),
        ),
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
          AppColors.pastelGreenBg,
          AppColors.accentGreenDark,
          'My Properties',
        ),
      if (isTenant)
        (
          Icons.apartment_rounded,
          AppColors.pastelGreenBg,
          AppColors.accentGreenDark,
          'My Flat',
        ),
      (
        Icons.notifications_none_rounded,
        AppColors.pastelBlueBg,
        AppColors.pastelBlueIcon,
        'Notification Preferences',
      ),
      (
        Icons.shield_outlined,
        AppColors.pastelRedBg,
        AppColors.danger,
        'Privacy & Security',
      ),
      (
        Icons.help_outline_rounded,
        AppColors.pastelGreenBg,
        AppColors.accentGreenDark,
        'Help & Support',
      ),
      (
        Icons.description_outlined,
        AppColors.surfaceMuted,
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
      color: AppColors.dangerBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.dangerBorder),
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
                  color: AppColors.textOnDark,
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
                      'Sign out of your Apart Mate account',
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

class _OwnerCard extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final void Function(String phone) onPhone;
  final void Function(String email) onEmail;

  const _OwnerCard({
    required this.name,
    required this.phone,
    required this.email,
    required this.onPhone,
    required this.onEmail,
  });

  @override
  State<_OwnerCard> createState() => _OwnerCardState();
}

class _OwnerCardState extends State<_OwnerCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.name.trim().isEmpty ? 'Property Owner' : widget.name.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROPERTY OWNER',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppColors.pastelGreenIcon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expanded ? 'Tap to collapse' : 'Tap for contact',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  _SocietyActionRow(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: widget.phone.isEmpty ? '—' : widget.phone,
                    actionIcon: Icons.call_rounded,
                    onTap: widget.phone.trim().isEmpty
                        ? null
                        : () => widget.onPhone(widget.phone),
                  ),
                  const SizedBox(height: 10),
                  _SocietyActionRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: widget.email.isEmpty ? '—' : widget.email,
                    actionIcon: Icons.mail_outline_rounded,
                    onTap: widget.email.trim().isEmpty
                        ? null
                        : () => widget.onEmail(widget.email),
                  ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}