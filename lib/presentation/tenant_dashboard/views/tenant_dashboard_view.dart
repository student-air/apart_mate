import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:apart_mate/core/constants/app_colors.dart';
// import 'package:apart_mate/core/constants/app_dimens.dart';
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
          AppSnackbar.info(
            'Complaints',
            'Complaint filing will be available soon',
          );
        },
      ),
      bottomNavigationBar: AppTenantBottomNav(
        activeTab: TenantNavTab.home,
        onHome: AppNavigation.goHome,
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onComplaints: () {
          AppSnackbar.info(
            'Complaints',
            'Complaints will be available soon',
          );
        },
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }
        return RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(controller: controller)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PropertyCard(controller: controller),
                    const SizedBox(height: 16),
                    _SocietyCard(controller: controller),
                    const SizedBox(height: 20),
                    Text('Quick actions', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    const _QuickActions(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Latest updates',
                            style: AppTextStyles.h4,
                          ),
                        ),
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
                    const SizedBox(height: 8),
                    if (controller.latestUpdates.isEmpty)
                      const _EmptyUpdates()
                    else
                      ...controller.latestUpdates.map(
                        (u) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _UpdateTile(update: u),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TenantDashboardController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Tenant',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${controller.greetingName}',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.societyName.isEmpty
                          ? 'Your tenant home'
                          : controller.societyName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Property card ────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final TenantDashboardController controller;
  const _PropertyCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.property.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    color: AppColors.pastelBlueIcon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My unit', style: AppTextStyles.overline),
                      const SizedBox(height: 2),
                      Text(
                        controller.propertyLabel,
                        style: AppTextStyles.h4,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.successGreenDark,
                    ),
                  ),
                ),
              ],
            ),
            if (p != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetaChip(
                      icon: Icons.apartment_rounded,
                      label: p.building,
                    ),
                  ),
                  Expanded(
                    child: _MetaChip(
                      icon: Icons.layers_rounded,
                      label: 'Floor ${p.floor}',
                    ),
                  ),
                  Expanded(
                    child: _MetaChip(
                      icon: Icons.door_front_door_rounded,
                      label: 'Flat ${p.flatNumber}',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Society card ─────────────────────────────────────────────────────────────

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
            'Society details will appear after your unit is linked.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
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
                Icons.location_city_rounded,
                color: AppColors.pastelGreenIcon,
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
                color: AppColors.accentGreen,
                size: 22,
              ),
          ],
        ),
      );
    });
  }
}

// ── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.report_problem_rounded,
            label: 'Complaint',
            bg: AppColors.pastelOrangeBg,
            iconColor: AppColors.pastelOrangeIcon,
            onTap: () {
              AppSnackbar.info(
                'Complaints',
                'Complaint filing will be available soon',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.campaign_rounded,
            label: 'Updates',
            bg: AppColors.pastelPurpleBg,
            iconColor: AppColors.pastelPurpleIcon,
            onTap: () => Get.toNamed(AppRoutes.updates),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.person_rounded,
            label: 'Profile',
            bg: AppColors.pastelBlueBg,
            iconColor: AppColors.pastelBlueIcon,
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Updates ──────────────────────────────────────────────────────────────────

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.pastelPurpleBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 18,
              color: AppColors.pastelPurpleIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(update.title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  update.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeago.format(update.postedAt),
                  style: AppTextStyles.overline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUpdates extends StatelessWidget {
  const _EmptyUpdates();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'No updates yet',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}