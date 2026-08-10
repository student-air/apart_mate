// lib/presentation/dashboard/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

        if (controller.isTenant) {
          return _TenantDashboardBody(controller: controller, society: society);
        }

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
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

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
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded,
                  size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppDimens.space16),
            Text(
              'No property found on your account yet.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
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

class _DashboardHeader extends StatelessWidget {
  final String societyName;
  final String greeting;
  final String userName;
  final String roleLabel;
  final bool showBuildingIllustration;

  const _DashboardHeader({
    required this.societyName,
    required this.greeting,
    required this.userName,
    required this.roleLabel,
    this.showBuildingIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space12,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: society + notification
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
                    societyName.toUpperCase(),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textOnDarkMuted,
                      letterSpacing: 0.7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primaryDark, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space20),

            // Greeting + illustration
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 24,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      Text(
                        '$userName.',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 24,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      if (roleLabel.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.space10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusFull),
                            border: Border.all(
                              color: AppColors.accentGreen.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_rounded,
                                  size: 13, color: AppColors.accentGreen),
                              const SizedBox(width: 5),
                              Text(
                                roleLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showBuildingIllustration) const _BuildingIllustration(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingIllustration extends StatelessWidget {
  const _BuildingIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 90,
      child: Image.asset(
        'assets/images/dashboard_building.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: 64,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.headerIllustrationAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.apartment_rounded,
                size: 76,
                color: AppColors.accentGreen.withValues(alpha: 0.9),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Owner Dashboard
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
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primaryDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _DashboardHeader(
              societyName: society.name,
              greeting: controller.greeting,
              userName: controller.userName,
              roleLabel: controller.roleLabel,
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space20,
              AppDimens.space20,
              AppDimens.space20,
              AppDimens.space32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Property hero
                _PropertyHeroCard(property: property),
                const SizedBox(height: AppDimens.space24),

                // Status section
                Text('PROPERTY STATUS', style: AppTextStyles.overline),
                const SizedBox(height: AppDimens.space12),
                _PropertyStatusGrid(
                  approved: controller.requestApproved.value,
                  property: property,
                ),
                const SizedBox(height: AppDimens.space20),

                // Occupancy
                _OccupancyCard(property: property),
                const SizedBox(height: AppDimens.space20),

                // Property details
                _PropertyDetailsCard(property: property),
                const SizedBox(height: AppDimens.space24),

                // Quick actions
                Text('QUICK ACTIONS', style: AppTextStyles.overline),
                const SizedBox(height: AppDimens.space12),
                const _QuickActionsRow(),
                const SizedBox(height: AppDimens.space24),

                // Latest updates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LATEST UPDATES', style: AppTextStyles.overline),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'View All',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.accentGreenDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space12),
                _LatestUpdatesList(updates: controller.updates),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tenant Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _TenantDashboardBody extends StatelessWidget {
  final DashboardController controller;
  final SocietyModel society;

  const _TenantDashboardBody({
    required this.controller,
    required this.society,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primaryDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              societyName: society.name,
              greeting: controller.greeting,
              userName: controller.userName,
              roleLabel: controller.roleLabel,
              showBuildingIllustration: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space20,
              AppDimens.space20,
              AppDimens.space20,
              AppDimens.space32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Membership status banner
                _MembershipBanner(
                  approved: controller.requestApproved.value,
                  societyName: society.name,
                ),
                const SizedBox(height: AppDimens.space24),

                // Quick actions
                Text('QUICK ACTIONS', style: AppTextStyles.overline),
                const SizedBox(height: AppDimens.space12),
                const _TenantQuickActionsRow(),
                const SizedBox(height: AppDimens.space24),

                // Latest updates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LATEST UPDATES', style: AppTextStyles.overline),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'View All',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.accentGreenDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space12),
                _LatestUpdatesList(updates: controller.updates),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cards & components
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyHeroCard extends StatelessWidget {
  final PropertyModel property;
  const _PropertyHeroCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            child: const Icon(Icons.home_rounded,
                size: 26, color: AppColors.pastelGreenIcon),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flat ${property.flatNumber}', style: AppTextStyles.h3),
                const SizedBox(height: 3),
                Text(
                  '${property.building} · ${property.floor}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
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

class _PropertyStatusGrid extends StatelessWidget {
  final bool approved;
  final PropertyModel property;
  const _PropertyStatusGrid({required this.approved, required this.property});

  @override
  Widget build(BuildContext context) {
    final tenantStatus = property.isOccupied ? 'Occupied' : 'Vacant';

    final items = [
      _StatusItem(
        icon: Icons.verified_user_rounded,
        label: 'Owner\nVerified',
        value: approved ? 'Verified' : 'Pending',
        bg: AppColors.pastelGreenBg,
        fg: AppColors.pastelGreenIcon,
        valueColor: approved ? AppColors.successGreenDark : AppColors.pending,
      ),
      _StatusItem(
        icon: Icons.fact_check_rounded,
        label: 'Property\nApproved',
        value: approved ? 'Approved' : 'Pending',
        bg: AppColors.pastelBlueBg,
        fg: AppColors.pastelBlueIcon,
        valueColor: approved ? AppColors.successGreenDark : AppColors.pending,
      ),
      _StatusItem(
        icon: Icons.person_rounded,
        label: 'Tenant\nStatus',
        value: tenantStatus,
        bg: AppColors.pastelOrangeBg,
        fg: AppColors.pastelOrangeIcon,
        valueColor: AppColors.textPrimary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.bg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 20, color: item.fg),
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600, height: 1.2),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: item.valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
class _StatusItem {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;
  final Color fg;
  final Color valueColor;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
    required this.valueColor,
  });
}

class _OccupancyCard extends StatelessWidget {
  final PropertyModel property;
  const _OccupancyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final isOccupied = property.isOccupied;
    final occupiedBy = property.occupiedBy;

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
            decoration: BoxDecoration(
              color: isOccupied
                  ? AppColors.pastelGreenBg
                  : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isOccupied ? Icons.person_rounded : Icons.person_off_rounded,
              size: 22,
              color: isOccupied
                  ? AppColors.pastelGreenIcon
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OCCUPANCY', style: AppTextStyles.overline),
                const SizedBox(height: 3),
                Text(
                  isOccupied
                      ? 'Occupied by ${occupiedBy.isEmpty ? '—' : occupiedBy[0].toUpperCase() + occupiedBy.substring(1)}'
                      : 'Currently Vacant',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyDetailsCard extends StatelessWidget {
  final PropertyModel property;
  const _PropertyDetailsCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, property.propertyType, 'Type'),
      (Icons.bed_rounded, property.flatType, 'Flat Type'),
      (Icons.square_foot_rounded,
          property.areaSqFt.isEmpty ? '—' : '${property.areaSqFt} sq ft', 'Area'),
      (Icons.bolt_rounded,
          property.meterType.isEmpty ? '—' : property.meterType, 'Electricity'),
      (Icons.local_fire_department_rounded,
          property.hasGas ? 'Available' : 'Not Available', 'Gas'),
      (Icons.chair_rounded,
          property.furnishing.isEmpty ? '—' : property.furnishing, 'Furnishing'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
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
              Text('PROPERTY DETAILS', style: AppTextStyles.overline),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.space16,
            crossAxisSpacing: AppDimens.space8,
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
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textMuted),
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

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.edit_rounded, 'Edit\nProperty', AppColors.pastelGreenBg,
          AppColors.pastelGreenIcon),
      (Icons.sync_alt_rounded, 'Transfer\nOwnership', AppColors.pastelOrangeBg,
          AppColors.pastelOrangeIcon),
      (Icons.build_rounded, 'Maintenance\nRequest', AppColors.pastelPurpleBg,
          AppColors.pastelPurpleIcon),
      (Icons.support_agent_rounded, 'Contact\nAdmin', AppColors.pastelRedBg,
          AppColors.pastelRedIcon),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppDimens.radius2xl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.space12, horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: action.$3,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(action.$1, size: 18, color: action.$4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
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
    );
  }
}
class _TenantQuickActionsRow extends StatelessWidget {
  const _TenantQuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.receipt_long_rounded, 'Rent &\nPayments', AppColors.pastelGreenBg,
          AppColors.pastelGreenIcon),
      (Icons.build_rounded, 'Maintenance\nRequest', AppColors.pastelPurpleBg,
          AppColors.pastelPurpleIcon),
      (Icons.description_rounded, 'Lease\nDocuments', AppColors.pastelBlueBg,
          AppColors.pastelBlueIcon),
      (Icons.support_agent_rounded, 'Contact\nAdmin', AppColors.pastelRedBg,
          AppColors.pastelRedIcon),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppDimens.radius2xl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.space12, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: action.$3,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(action.$1, size: 19, color: action.$4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
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
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  final bool approved;
  final String societyName;
  const _MembershipBanner({required this.approved, required this.societyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: approved ? AppColors.pastelGreenBg : AppColors.pendingBg,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(
          color: approved
              ? AppColors.accentGreen.withValues(alpha: 0.25)
              : AppColors.pending.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            approved ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            size: 22,
            color: approved ? AppColors.successGreenDark : AppColors.pending,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Text(
              approved
                  ? 'You\'re a verified tenant at $societyName'
                  : 'Your membership request is pending review',
              style: AppTextStyles.bodyMedium.copyWith(
                color: approved ? AppColors.successGreenDark : AppColors.pending,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestUpdatesList extends StatelessWidget {
  final List<DashboardUpdateItem> updates;
  const _LatestUpdatesList({required this.updates});

  (IconData, Color, Color) _visualsFor(DashboardUpdateType type) {
    switch (type) {
      case DashboardUpdateType.announcement:
        return (
          Icons.campaign_rounded,
          AppColors.pastelBlueBg,
          AppColors.pastelBlueIcon
        );
      case DashboardUpdateType.propertyUpdate:
        return (
          Icons.assignment_rounded,
          AppColors.pastelOrangeBg,
          AppColors.pastelOrangeIcon
        );
      case DashboardUpdateType.verification:
        return (
          Icons.check_circle_rounded,
          AppColors.pastelGreenBg,
          AppColors.pastelGreenIcon
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius2xl),
          border: Border.all(color: AppColors.borderLight),
        ),
        alignment: Alignment.center,
        child: Text(
          'No updates yet',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: List.generate(updates.length, (i) {
          final update = updates[i];
          final (icon, bg, fg) = _visualsFor(update.type);
          final isLast = i == updates.length - 1;

          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? const Radius.circular(AppDimens.radius2xl) : Radius.zero,
              bottom: isLast
                  ? const Radius.circular(AppDimens.radius2xl)
                  : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.borderLight)),
              ),
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
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(update.title, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(update.postedAt),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}