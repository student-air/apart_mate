// lib/presentation/tenant_dashboard/views/tenant_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_drawer.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/core/widgets/app_tenant_bottom_nav.dart';
import 'package:apart_mate/data/models/update_model.dart';
import 'package:apart_mate/presentation/tenant_dashboard/controllers/tenant_dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class TenantDashboardView extends GetView<TenantDashboardController> {
  const TenantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Obx(
        () => AppDrawer(
          userName: controller.userName,
          roleLabel: controller.roleLabel,
          societyName: controller.societyName,
          isTenant: true,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(
        onPressed: () {
          AppSnackbar.info('Complaints', 'Complaint filing will be available soon');
        },
      ),
      // ── KEEP TENANT NAV AS-IS ───────────────────────────────────────────
      bottomNavigationBar: AppTenantBottomNav(
        activeTab: TenantNavTab.home,
        onHome: AppNavigation.goHome,
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onComplaints: () {
          AppSnackbar.info('Complaints', 'Complaints will be available soon');
        },
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
              ContainedSliverPadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusRow(controller: controller),
                    const SizedBox(height: 16),
                    _MyUnitCard(controller: controller),
                    const SizedBox(height: 14),
                    _SocietyCard(controller: controller),
                    const SizedBox(height: 20),
                    const _QuickActionsCard(),
                    const SizedBox(height: 20),
                    _LatestUpdates(controller: controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Simple padding helper as a sliver
class ContainedSliverPadding extends StatelessWidget {
  final Widget child;
  const ContainedSliverPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverToBoxAdapter(child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TOP — same language as owner dashboard (light, not dark header)
// ═══════════════════════════════════════════════════════════════════════════

class _TopSection extends StatelessWidget {
  final TenantDashboardController controller;
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
            // Menu · society · bell · avatar
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
                          ? 'MY UNIT'
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
                      border: Border.all(color: AppColors.borderLight, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.userName.isNotEmpty
                          ? controller.userName[0].toUpperCase()
                          : 'T',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.accentGreenDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Greeting + date card
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
                          color: AppColors.pastelBlueBg,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          border: Border.all(
                            color: AppColors.pastelBlueIcon.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.key_rounded,
                              size: 13,
                              color: AppColors.pastelBlueIcon,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tenant',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.pastelBlueIcon,
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

// ═══════════════════════════════════════════════════════════════════════════
// STATUS CHIPS (tenant-relevant)
// ═══════════════════════════════════════════════════════════════════════════

class _StatusRow extends StatelessWidget {
  final TenantDashboardController controller;
  const _StatusRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasUnit = controller.property.value != null;
      final hasSociety = controller.society.value != null;

      return Row(
        children: [
          Expanded(
            child: _StatusChip(
              icon: Icons.verified_user_rounded,
              iconBg: AppColors.pastelGreenBg,
              iconColor: AppColors.pastelGreenIcon,
              value: hasUnit ? 'Active' : '—',
              label: 'Tenancy',
              sub: hasUnit ? 'Joined' : 'Pending',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatusChip(
              icon: Icons.home_rounded,
              iconBg: AppColors.pastelBlueBg,
              iconColor: AppColors.pastelBlueIcon,
              value: hasUnit ? 'Yes' : 'No',
              label: 'Unit',
              sub: hasUnit ? 'Linked' : 'None',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatusChip(
              icon: Icons.apartment_rounded,
              iconBg: AppColors.pastelOrangeBg,
              iconColor: AppColors.pastelOrangeIcon,
              value: hasSociety ? 'Yes' : '—',
              label: 'Society',
              sub: hasSociety ? 'Linked' : '—',
            ),
          ),
        ],
      );
    });
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String sub;

  const _StatusChip({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(fontSize: 16),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            sub,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accentGreenDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MY UNIT
// ═══════════════════════════════════════════════════════════════════════════

class _MyUnitCard extends StatelessWidget {
  final TenantDashboardController controller;
  const _MyUnitCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.property.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pastelGreenBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: AppColors.pastelGreenIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p == null ? 'My unit' : 'Flat ${p.flatNumber}',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p == null
                        ? 'No unit linked yet'
                        : [
                            if (p.building.isNotEmpty) p.building,
                            if (p.floor.isNotEmpty) p.floor,
                          ].join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.pastelGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p == null ? 'Pending' : 'Active',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentGreenDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOCIETY
// ═══════════════════════════════════════════════════════════════════════════

class _SocietyCard extends StatelessWidget {
  final TenantDashboardController controller;
  const _SocietyCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.society.value;
      if (s == null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Society details will show once your unit is linked.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pastelBlueBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.pastelBlueIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Text(
                    '${s.address}, ${s.city}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (s.isVerified)
              const Icon(
                Icons.verified_rounded,
                size: 20,
                color: AppColors.accentGreenDark,
              ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK ACTIONS (tenant-focused)
// ═══════════════════════════════════════════════════════════════════════════

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.report_problem_rounded,
                  label: 'Complaint',
                  bg: AppColors.pastelRedBg,
                  fg: AppColors.pastelRedIcon,
                  onTap: () => AppSnackbar.info(
                    'Complaints',
                    'Coming soon',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.build_rounded,
                  label: 'Maintenance',
                  bg: AppColors.surfaceMuted,
                  fg: AppColors.textSecondary,
                  onTap: () => AppSnackbar.info(
                    'Maintenance',
                    'Coming soon',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.campaign_rounded,
                  label: 'Updates',
                  bg: AppColors.pastelBlueBg,
                  fg: AppColors.pastelBlueIcon,
                  onTap: () => Get.toNamed(AppRoutes.updates),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Contact',
                  bg: AppColors.pastelOrangeBg,
                  fg: AppColors.pastelOrangeIcon,
                  onTap: () => AppSnackbar.info(
                    'Contact',
                    'Coming soon',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  bg: AppColors.pastelGreenBg,
                  fg: AppColors.pastelGreenIcon,
                  onTap: () => Get.toNamed(AppRoutes.profile),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPDATES
// ═══════════════════════════════════════════════════════════════════════════

class _LatestUpdates extends StatelessWidget {
  final TenantDashboardController controller;
  const _LatestUpdates({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Latest updates', style: AppTextStyles.h4)),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.updates),
              child: Text(
                'See all',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentGreenDark,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (controller.latestUpdates.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'No updates yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return Column(
            children: controller.latestUpdates
                .map(
                  (u) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UpdateTile(update: u),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final UpdateModel update;
  const _UpdateTile({required this.update});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
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
                  update.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(update.postedAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
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