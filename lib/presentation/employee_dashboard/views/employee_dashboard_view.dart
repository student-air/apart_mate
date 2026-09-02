// lib/presentation/employee_dashboard/views/employee_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_drawer.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/core/widgets/app_tenant_bottom_nav.dart';
import 'package:apart_mate/core/widgets/send_complaint_sheet.dart';
import 'package:apart_mate/presentation/employee_dashboard/controllers/employee_dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Obx(
        () => AppDrawer(
          userName: controller.userName.value,
          roleLabel: controller.roleLabel,
          societyName: controller.societyName,
          isTenant: true, // same drawer style as tenant shell
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(
        onPressed: () => SendComplaintSheet.open(),
      ),
      // Same navbar as tenant
      bottomNavigationBar: AppTenantBottomNav(
        activeTab: TenantNavTab.home,
        onHome: () => AppNavigation.goHome(),
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onComplaints: () => Get.toNamed(AppRoutes.complaint),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoading();

        return RefreshIndicator(
          color: AppColors.accentGreenDark,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _TopSection(controller: controller)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatusRow(controller: controller),
                      const SizedBox(height: 16),
                      _SocietyCard(controller: controller),
                      const SizedBox(height: 14),
                      _RoleCard(controller: controller),
                      const SizedBox(height: 20),
                      Text('Quick actions', style: AppTextStyles.h4),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.campaign_rounded,
                              label: 'Updates',
                              onTap: controller.openUpdates,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.report_problem_rounded,
                              label: 'Complaints',
                              onTap: controller.openComplaints,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        onTap: controller.openProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Top (light, same as tenant/owner) ─────────────────────────────────────

class _TopSection extends StatelessWidget {
  final EmployeeDashboardController controller;
  const _TopSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.societyName.isEmpty
                          ? 'STAFF'
                          : controller.societyName.toUpperCase(),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.toNamed(AppRoutes.updates),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profile),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreenBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                      () => Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'S',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.accentGreenDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()},',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.greetingName}.',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.accentGreenDark,
                            fontSize: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pastelOrangeBg,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          border: Border.all(
                            color: AppColors.pastelOrangeIcon
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_rounded,
                              size: 13,
                              color: AppColors.pastelOrangeIcon,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Staff',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.pastelOrangeIcon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DateCard(now: now),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _DateCard extends StatelessWidget {
  final DateTime now;
  const _DateCard({required this.now});

  @override
  Widget build(BuildContext context) {
    final hour = now.hour;
    late IconData timeIcon;
    late String timeLabel;
    late Color timeColor;

    if (hour >= 5 && hour < 12) {
      timeIcon = Icons.wb_sunny_rounded;
      timeLabel = 'Morning';
      timeColor = const Color(0xFFF59E0B);
    } else if (hour >= 12 && hour < 17) {
      timeIcon = Icons.wb_sunny_outlined;
      timeLabel = 'Afternoon';
      timeColor = const Color(0xFFF97316);
    } else if (hour >= 17 && hour < 20) {
      timeIcon = Icons.wb_twilight_rounded;
      timeLabel = 'Evening';
      timeColor = const Color(0xFF8B5CF6);
    } else {
      timeIcon = Icons.nightlight_round;
      timeLabel = 'Night';
      timeColor = const Color(0xFF6366F1);
    }

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                "Today's Date",
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('d MMM yyyy, EEEE').format(now),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(timeIcon, size: 17, color: timeColor),
              const SizedBox(width: 6),
              Text(
                timeLabel,
                style: AppTextStyles.labelMedium.copyWith(
                  color: timeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final EmployeeDashboardController controller;
  const _StatusRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'Staff',
            icon: Icons.badge_rounded,
            bg: AppColors.pastelOrangeBg,
            fg: AppColors.pastelOrangeIcon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => _Chip(
              label: controller.societyName.isEmpty
                  ? 'No society'
                  : 'Active',
              icon: Icons.verified_rounded,
              bg: AppColors.pastelGreenBg,
              fg: AppColors.accentGreenDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _Chip({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocietyCard extends StatelessWidget {
  final EmployeeDashboardController controller;
  const _SocietyCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.society.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Society',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s?.name ?? '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((s?.address ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      s!.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RoleCard extends StatelessWidget {
  final EmployeeDashboardController controller;
  const _RoleCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pastelOrangeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: AppColors.pastelOrangeIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Society staff',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Approved by society admin',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryDark),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}