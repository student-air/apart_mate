// lib/presentation/dashboard/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';

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
      // lib/presentation/dashboard/views/dashboard_view.dart — replace the Obx body content

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

        return _OwnerDashboardBody(controller: controller, society: society, property: property);
      }),
    );
  }
}

/// Shown when the user has no property/society on record — e.g. they
/// skipped part of onboarding or hit an edge case. Prevents a crash on
/// null data instead of assuming onboarding always completes.
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
            const Icon(Icons.info_outline_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimens.space16),
            Text(
              'No property found on your account yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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

class _TopBar extends StatelessWidget {
  final String societyName;
  const _TopBar({required this.societyName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              societyName.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
            ),
          ],
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
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textPrimary),
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
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final DashboardController controller;
  const _GreetingHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${controller.greeting},', style: AppTextStyles.h1.copyWith(fontSize: 24)),
              Text(
                '${controller.userName}.',
                style: AppTextStyles.h1.copyWith(fontSize: 24, color: AppColors.accentGreenDark),
              ),
              const SizedBox(height: AppDimens.space8),
              if (controller.roleLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(controller.roleLabel, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.space12),
        _BuildingIllustration(),
      ],
    );
  }
}

/// Building graphic in the header. Uses assets/images/dashboard_building.png
/// if present, falling back to a simple icon composition so the layout
/// never breaks if the asset is missing (same defensive pattern used for
/// the logo elsewhere in the app).
class _BuildingIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 100,
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
                  width: 70,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                ),
              ),
              Icon(Icons.apartment_rounded, size: 84, color: AppColors.pastelGreenIcon.withValues(alpha: 0.85)),
            ],
          );
        },
      ),
    );
  }
}

class _FlatSelector extends StatelessWidget {
  final dynamic property; // PropertyModel
  const _FlatSelector({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.pastelGreenBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.home_rounded, size: 22, color: AppColors.pastelGreenIcon),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flat ${property.flatNumber}', style: AppTextStyles.h4),
                Text(
                  property.building as String,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
         // const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PropertyStatusGrid extends StatelessWidget {
  final bool approved;
  final dynamic property; // PropertyModel
  const _PropertyStatusGrid({required this.approved, required this.property});

  @override
  Widget build(BuildContext context) {
    final tenantStatus = (property.isOccupied as bool) ? 'Occupied' : 'Vacant';

    final items = [
      (
        icon: Icons.verified_user_rounded,
        label: 'Owner\nVerified',
        value: approved ? 'Verified' : 'Pending',
        bg: AppColors.pastelGreenBg,
        fg: AppColors.pastelGreenIcon,
      ),
      (
        icon: Icons.groups_rounded,
        label: 'Property Approved',
        value: approved ? 'Approved' : 'Pending',
        bg: AppColors.pastelBlueBg,
        fg: AppColors.pastelBlueIcon,
      ),
      (
        icon: Icons.person_rounded,
        label: 'Tenant\nStatus',
        value: tenantStatus,
        bg: AppColors.pastelOrangeBg,
        fg: AppColors.pastelOrangeIcon,
      ),
      (
        icon: Icons.description_rounded,
        label: 'Document\nStatus',
        value: approved ? 'Verified' : 'Pending',
        bg: AppColors.pastelPurpleBg,
        fg: AppColors.pastelPurpleIcon,
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
                  decoration: BoxDecoration(color: item.bg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 20, color: item.fg),
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(item.value, style: AppTextStyles.labelSmall.copyWith(color: AppColors.successGreenDark)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Replaces the old "Current Tenant" card. We don't collect a tenant's
/// name/phone anywhere in onboarding (property_details only records who
/// occupies the flat — owner or tenant — not a separate person's
/// identity), so this shows real occupancy info without fabricating a
/// tenant's name.
class _OccupancyCard extends StatelessWidget {
  final dynamic property; // PropertyModel
  const _OccupancyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final isOccupied = property.isOccupied as bool;
    final occupiedBy = property.occupiedBy as String;

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
            decoration: const BoxDecoration(color: AppColors.pastelGreenBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              isOccupied ? Icons.person_rounded : Icons.person_off_rounded,
              size: 24,
              color: AppColors.pastelGreenIcon,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OCCUPANCY', style: AppTextStyles.overline),
                const SizedBox(height: 2),
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
  final dynamic property; // PropertyModel
  const _PropertyDetailsCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_rounded, value: property.propertyType as String, label: 'Type'),
      (icon: Icons.bed_rounded, value: property.flatType as String, label: 'Flat Type'),
      (icon: Icons.square_foot_rounded, value: '${property.areaSqFt} sq ft', label: 'Area'),
      (
        icon: Icons.bolt_rounded,
        value: (property.meterType as String).isEmpty ? '—' : property.meterType as String,
        label: 'Electricity',
      ),
      (
        icon: Icons.local_fire_department_rounded,
        value: (property.hasGas as bool) ? 'Available' : 'Not Available',
        label: 'Gas Type',
      ),
      (
        icon: Icons.chair_rounded,
        value: (property.furnishing as String).isEmpty ? '—' : property.furnishing as String,
        label: 'Furnishing',
      ),
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
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.space16,
            crossAxisSpacing: AppDimens.space8,
            childAspectRatio: 1.1,
            children: items.map((item) {
              return Column(
                children: [
                  Icon(item.icon, size: 22, color: AppColors.accentGreenDark),
                  const SizedBox(height: 6),
                  Text(item.value, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                  Text(item.label, textAlign: TextAlign.center, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Fixed 5-across row (not a scrolling carousel), matching the mockup —
/// each icon squeezes into an equal-width Expanded slot instead of
/// scrolling horizontally.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.edit_rounded, label: 'Edit Property', bg: AppColors.pastelGreenBg, fg: AppColors.pastelGreenIcon),
      (icon: Icons.description_rounded, label: 'Documents', bg: AppColors.pastelBlueBg, fg: AppColors.pastelBlueIcon),
      (icon: Icons.sync_alt_rounded, label: 'Transfer\nOwnership', bg: AppColors.pastelOrangeBg, fg: AppColors.pastelOrangeIcon),
      (icon: Icons.build_rounded, label: 'Maintenance\nRequest', bg: AppColors.pastelPurpleBg, fg: AppColors.pastelPurpleIcon),
      (icon: Icons.support_agent_rounded, label: 'Contact Admin', bg: AppColors.pastelRedBg, fg: AppColors.pastelRedIcon),
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
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space12, horizontal: 4),
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
                      decoration: BoxDecoration(color: action.bg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(action.icon, size: 19, color: action.fg),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 9.5),
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

class _LatestUpdatesList extends StatelessWidget {
  final List<DashboardUpdateItem> updates;
  const _LatestUpdatesList({required this.updates});

  (IconData, Color, Color) _visualsFor(DashboardUpdateType type) {
    switch (type) {
      case DashboardUpdateType.announcement:
        return (Icons.campaign_rounded, AppColors.pastelBlueBg, AppColors.pastelBlueIcon);
      case DashboardUpdateType.propertyUpdate:
        return (Icons.assignment_rounded, AppColors.pastelOrangeBg, AppColors.pastelOrangeIcon);
      case DashboardUpdateType.verification:
        return (Icons.check_circle_rounded, AppColors.pastelGreenBg, AppColors.pastelGreenIcon);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius2xl),
          border: Border.all(color: AppColors.borderLight),
        ),
        alignment: Alignment.center,
        child: Text('No updates yet', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
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
            child: Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: fg),
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
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OwnerDashboardBody extends StatelessWidget {
  final DashboardController controller;
  final dynamic society; // SocietyModel
  final dynamic property; // PropertyModel
  const _OwnerDashboardBody({required this.controller, required this.society, required this.property});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primaryDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.space20,
          AppDimens.space16,
          AppDimens.space20,
          AppDimens.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(societyName: society.name),
            const SizedBox(height: AppDimens.space20),
            _GreetingHeader(controller: controller),
            const SizedBox(height: AppDimens.space20),
            _FlatSelector(property: property),
            const SizedBox(height: AppDimens.space24),
            Text('PROPERTY STATUS', style: AppTextStyles.overline),
            const SizedBox(height: AppDimens.space12),
            _PropertyStatusGrid(approved: controller.requestApproved.value, property: property),
            const SizedBox(height: AppDimens.space20),
            _OccupancyCard(property: property),
            const SizedBox(height: AppDimens.space20),
            _PropertyDetailsCard(property: property),
            const SizedBox(height: AppDimens.space20),
            Text('QUICK ACTIONS', style: AppTextStyles.overline),
            const SizedBox(height: AppDimens.space12),
            const _QuickActionsRow(),
            const SizedBox(height: AppDimens.space20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LATEST UPDATES', style: AppTextStyles.overline),
                InkWell(
                  onTap: () {},
                  child: Text('View All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentGreenDark)),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            _LatestUpdatesList(updates: controller.updates),
          ],
        ),
      ),
    );
  }
}
class _TenantDashboardBody extends StatelessWidget {
  final DashboardController controller;
  final dynamic society; // SocietyModel
  const _TenantDashboardBody({required this.controller, required this.society});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primaryDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.space20,
          AppDimens.space16,
          AppDimens.space20,
          AppDimens.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(societyName: society.name),
            const SizedBox(height: AppDimens.space20),
            _GreetingHeader(controller: controller),
            const SizedBox(height: AppDimens.space24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: controller.requestApproved.value ? AppColors.pastelGreenBg : AppColors.pendingBg,
                borderRadius: BorderRadius.circular(AppDimens.radius2xl),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.requestApproved.value ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                    size: 22,
                    color: controller.requestApproved.value ? AppColors.successGreenDark : AppColors.pending,
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Text(
                      controller.requestApproved.value
                          ? 'You\'re a verified tenant at ${society.name}'
                          : 'Your membership request is pending review',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: controller.requestApproved.value ? AppColors.successGreenDark : AppColors.pending,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            Text('QUICK ACTIONS', style: AppTextStyles.overline),
            const SizedBox(height: AppDimens.space12),
            const _TenantQuickActionsRow(),
            const SizedBox(height: AppDimens.space20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LATEST UPDATES', style: AppTextStyles.overline),
                InkWell(
                  onTap: () {},
                  child: Text('View All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentGreenDark)),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            _LatestUpdatesList(updates: controller.updates),
          ],
        ),
      ),
    );
  }
}

class _TenantQuickActionsRow extends StatelessWidget {
  const _TenantQuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.receipt_long_rounded, label: 'Rent &\nPayments', bg: AppColors.pastelGreenBg, fg: AppColors.pastelGreenIcon),
      (icon: Icons.build_rounded, label: 'Maintenance\nRequest', bg: AppColors.pastelPurpleBg, fg: AppColors.pastelPurpleIcon),
      (icon: Icons.description_rounded, label: 'Lease\nDocuments', bg: AppColors.pastelBlueBg, fg: AppColors.pastelBlueIcon),
      (icon: Icons.support_agent_rounded, label: 'Contact\nAdmin', bg: AppColors.pastelRedBg, fg: AppColors.pastelRedIcon),
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
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space12, horizontal: 4),
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
                      decoration: BoxDecoration(color: action.bg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(action.icon, size: 19, color: action.fg),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 9.5),
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