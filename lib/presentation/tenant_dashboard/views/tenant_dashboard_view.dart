import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/presentation/tenant_dashboard/controllers/tenant_dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class TenantDashboardView extends GetView<TenantDashboardController> {
  const TenantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(
        onPressed: () {
          AppSnackbar.info('Actions', 'Coming soon');
        },
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.home,
        onHome: () {},
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onMembers: () => Get.toNamed(AppRoutes.members),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.accentGreenDark,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.propertyLabel.toUpperCase(),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                              controller.firstName.isNotEmpty
                                  ? controller.firstName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accentGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Greeting + date
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
                                  '${controller.firstName}.',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.accentGreenDark,
                                    fontSize: 36,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                        controller.roleLabel,
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusLg,
                              ),
                              border:
                                  Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Today's Date",
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('d MMM yyyy').format(now),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE').format(now),
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
                ),
              ),
            ),

            // My unit card
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MyUnitCard(controller: controller),
              ),
            ),

            // Quick actions
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: AppTextStyles.h4,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.build_rounded,
                        label: 'Maintenance',
                        color: AppColors.pastelOrangeBg,
                        iconColor: AppColors.pastelOrangeIcon,
                        onTap: () =>
                            AppSnackbar.info('Maintenance', 'Coming soon'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.report_problem_rounded,
                        label: 'Complaint',
                        color: AppColors.pastelPinkBg,
                        iconColor: AppColors.pastelPinkIcon,
                        onTap: () =>
                            AppSnackbar.info('Complaint', 'Coming soon'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.chat_rounded,
                        label: 'Contact',
                        color: AppColors.pastelBlueBg,
                        iconColor: AppColors.pastelBlueIcon,
                        onTap: () =>
                            AppSnackbar.info('Contact', 'Coming soon'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Updates preview
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Latest Updates', style: AppTextStyles.h4),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.updates),
                      child: Text(
                        'View all',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.accentGreenDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radius2xl),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 36,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No updates yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyUnitCard extends StatelessWidget {
  final TenantDashboardController controller;
  const _MyUnitCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = controller.property;
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.pastelGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
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
                      'My Unit',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'Flat ${p.flatNumber}',
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreenBg,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentGreenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            [
              if (p.building.isNotEmpty) p.building,
              if (p.floor.isNotEmpty) p.floor,
              if (p.flatType.isNotEmpty) p.flatType,
            ].join(' · ').isEmpty
                ? controller.propertyLabel
                : [
                    if (p.building.isNotEmpty) p.building,
                    if (p.floor.isNotEmpty) p.floor,
                    if (p.flatType.isNotEmpty) p.flatType,
                  ].join(' · '),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}