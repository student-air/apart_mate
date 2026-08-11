// lib/presentation/dashboard/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(onPressed: () {}),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.home,
        onHome: () => Get.offNamed(AppRoutes.dashboard),
        onUpdates: () {},
        onRequests: () {},
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        final society = controller.society.value;
        if (society == null) {
          return _NoDataState(onRetry: controller.refresh);
        }

        // Focus is owner only for now
        final property = controller.property.value;
        if (property == null) {
          return _NoDataState(onRetry: controller.refresh);
        }

        return _OwnerDashboardBody(
          controller: controller,
          society: society,
          property: property,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

void _showComingSoon(String feature) {
  Get.snackbar(
    feature,
    'Coming soon',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
  );
}

class _NoDataState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _NoDataState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 32,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Text(
              'No property found on your account yet.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Owner Dashboard (Admin-style layout)
// ─────────────────────────────────────────────────────────────────────────────

class _OwnerDashboardBody extends StatelessWidget {
  final DashboardController controller;
  final SocietyModel society;
  final PropertyModel property;

  const _OwnerDashboardBody({
    required this.controller,
    required this.society,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('d MMM yyyy, EEE').format(now);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.accentGreenDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: society + actions
                    Row(
                      children: [
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
                          child: Text(
                            society.name.toUpperCase(),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Notification
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar placeholder
                        Container(
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
                          child: Text(
                            controller.userName.isNotEmpty
                                ? controller.userName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.accentGreenDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Greeting + bigger date card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.greeting},',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${controller.userName}.',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.accentGreenDark,
                                  fontSize: 34,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Role badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pastelGreenBg,
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: AppColors.accentGreen
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 13,
                                      color: AppColors.accentGreenDark,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.roleLabel.isEmpty
                                          ? 'Owner'
                                          : controller.roleLabel,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accentGreenDark,
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

                        // Bigger date + time-of-day card
                        // Bigger date + time-of-day card
Builder(
  builder: (context) {
    final hour = DateTime.now().hour;
    late IconData timeIcon;
    late String timeLabel;
    late Color timeColor;

    if (hour >= 5 && hour < 12) {
      timeIcon = Icons.wb_sunny_rounded;
      timeLabel = 'Morning';
      timeColor = const Color(0xFFF59E0B); // yellow/amber
    } else if (hour >= 12 && hour < 17) {
      timeIcon = Icons.wb_sunny_outlined;
      timeLabel = 'Afternoon';
      timeColor = const Color(0xFFF97316); // orange
    } else if (hour >= 17 && hour < 20) {
      timeIcon = Icons.wb_twilight_rounded;
      timeLabel = 'Evening';
      timeColor = const Color(0xFF8B5CF6); // soft purple
    } else {
      timeIcon = Icons.nightlight_round;
      timeLabel = 'Night';
      timeColor = const Color(0xFF6366F1); // indigo
    }

    // Full day name: Tuesday, Wednesday, etc.
    final fullDateStr = DateFormat('d MMM yyyy, EEEE').format(now);

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
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
            fullDateStr,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                timeIcon,
                size: 17,
                color: timeColor,
              ),
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
  },
),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Metric cards (4)
                _MetricCardsRow(
                  approved: controller.requestApproved.value,
                  property: property,
                ),
                const SizedBox(height: 20),

                // Property hero
                _PropertyHeroCard(property: property),
                const SizedBox(height: 20),

                // Quick Actions
                _QuickActionsCard(),
                const SizedBox(height: 20),

                // Property Details
                _PropertyDetailsCard(property: property),
                const SizedBox(height: 20),

                // Latest Updates
                _LatestUpdatesSection(updates: controller.updates),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Metric cards (same style as admin Buildings / Owners / etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCardsRow extends StatelessWidget {
  final bool approved;
  final PropertyModel property;

  const _MetricCardsRow({
    required this.approved,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final tenantStatus = property.isOccupied ? 'Occupied' : 'Vacant';

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.verified_user_rounded,
            iconBg: AppColors.pastelGreenBg,
            iconColor: AppColors.pastelGreenIcon,
            value: approved ? 'Yes' : 'No',
            label: 'Owner\nVerified',
            subLabel: approved ? 'Verified' : 'Pending',
            subColor: approved
                ? AppColors.successGreenDark
                : AppColors.pending,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.fact_check_rounded,
            iconBg: AppColors.pastelBlueBg,
            iconColor: AppColors.pastelBlueIcon,
            value: approved ? 'Yes' : 'No',
            label: 'Property\nApproved',
            subLabel: approved ? 'Approved' : 'Pending',
            subColor: approved
                ? AppColors.successGreenDark
                : AppColors.pending,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.person_rounded,
            iconBg: AppColors.pastelOrangeBg,
            iconColor: AppColors.pastelOrangeIcon,
            value: property.isOccupied ? '1' : '0',
            label: 'Tenant\nStatus',
            subLabel: tenantStatus,
            subColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.description_rounded,
            iconBg: AppColors.pastelPurpleBg,
            iconColor: AppColors.pastelPurpleIcon,
            value: approved ? 'OK' : '--',
            label: 'Documents',
            subLabel: approved ? 'Verified' : 'Pending',
            subColor: approved
                ? AppColors.successGreenDark
                : AppColors.pending,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String subLabel;
  final Color subColor;

  const _MetricCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: subColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Property Hero
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyHeroCard extends StatelessWidget {
  final PropertyModel property;
  const _PropertyHeroCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.home_rounded,
              size: 26,
              color: AppColors.pastelGreenIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flat ${property.flatNumber}',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 2),
                Text(
                  '${property.building} · ${property.floor}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              property.propertyType,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.successGreenDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions (admin style)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.edit_rounded,
        'Edit\nProperty',
        AppColors.pastelGreenBg,
        AppColors.pastelGreenIcon,
        () => _showComingSoon('Edit Property'),
      ),
      (
        Icons.description_rounded,
        'Edit\nDocuments',
        AppColors.pastelBlueBg,
        AppColors.pastelBlueIcon,
        () => _showComingSoon('Documents'),
      ),
      (
        Icons.sync_alt_rounded,
        'Transfer\nOwnership',
        AppColors.pastelOrangeBg,
        AppColors.pastelOrangeIcon,
        () => _showComingSoon('Transfer Ownership'),
      ),
      (
        Icons.build_rounded,
        'Maintenanc\nStatus',
        AppColors.pastelPurpleBg,
        AppColors.pastelPurpleIcon,
        () => _showComingSoon('Maintenance Request'),
      ),
      (
        Icons.support_agent_rounded,
        'Contact\nAdmin',
        AppColors.pastelRedBg,
        AppColors.pastelRedIcon,
        () => _showComingSoon('Contact Admin'),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.h4.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: a.$5,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: a.$3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(a.$1, size: 20, color: a.$4),
                          const SizedBox(height: 6),
                          Text(
                            a.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: a.$4,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Property Details
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyDetailsCard extends StatelessWidget {
  final PropertyModel property;
  const _PropertyDetailsCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, property.propertyType, 'Type'),
      (Icons.bed_rounded, property.flatType, 'Flat Type'),
      (
        Icons.square_foot_rounded,
        property.areaSqFt.isEmpty ? '—' : '${property.areaSqFt} sq ft',
        'Area',
      ),
      (
        Icons.bolt_rounded,
        property.meterType.isEmpty ? '—' : property.meterType,
        'Electricity',
      ),
      (
        Icons.local_fire_department_rounded,
        property.hasGas ? 'Available' : 'Not Available',
        'Gas',
      ),
      (
        Icons.chair_rounded,
        property.furnishing.isEmpty ? '—' : property.furnishing,
        'Furnishing',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Details',
            style: AppTextStyles.h4.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: items.map((item) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$1, size: 22, color: AppColors.accentGreenDark),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Latest Updates (Recent Activity style)
// ─────────────────────────────────────────────────────────────────────────────

class _LatestUpdatesSection extends StatelessWidget {
  final List<DashboardUpdateItem> updates;
  const _LatestUpdatesSection({required this.updates});

  (IconData, Color, Color) _visuals(DashboardUpdateType type) {
    switch (type) {
      case DashboardUpdateType.announcement:
        return (
          Icons.campaign_rounded,
          AppColors.pastelBlueBg,
          AppColors.pastelBlueIcon,
        );
      case DashboardUpdateType.propertyUpdate:
        return (
          Icons.assignment_rounded,
          AppColors.pastelOrangeBg,
          AppColors.pastelOrangeIcon,
        );
      case DashboardUpdateType.verification:
        return (
          Icons.check_circle_rounded,
          AppColors.pastelGreenBg,
          AppColors.pastelGreenIcon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Updates',
                style: AppTextStyles.h4.copyWith(fontSize: 16),
              ),
              InkWell(
                onTap: () => _showComingSoon('Updates'),
                child: Text(
                  'View All',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accentGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (updates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No updates yet',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...List.generate(updates.length, (i) {
              final u = updates[i];
              final (icon, bg, fg) = _visuals(u.type);
              final isLast = i == updates.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, size: 18, color: fg),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.title,
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeago.format(u.postedAt),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.borderLight),
                ],
              );
            }),
        ],
      ),
    );
  }
}