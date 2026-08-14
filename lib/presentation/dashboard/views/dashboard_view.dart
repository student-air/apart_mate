// lib/presentation/dashboard/views/dashboard_view.dart

import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_drawer.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
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
      drawer: AppDrawer(
  userName: controller.userName,
  roleLabel: controller.roleLabel,
  societyName: controller.society.value?.name ?? '',
  isTenant: AppNavigation.isTenant,
),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(onPressed: () {}),
      bottomNavigationBar: AppBottomNav(
  items: [
    NavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
      isActive: true,
      onTap: AppNavigation.goHome,
    ),
    NavItemData(
      icon: Icons.campaign_rounded,
      label: 'Updates',
      isActive: false,
      onTap: () => Get.toNamed(AppRoutes.updates),
    ),
    NavItemData(
      icon: Icons.groups_rounded,
      label: 'Members',
      isActive: false,
      onTap: () => Get.toNamed(AppRoutes.members),
    ),
    NavItemData(
      icon: Icons.person_rounded,
      label: 'Profile',
      isActive: false,
      onTap: () => Get.toNamed(AppRoutes.profile),
    ),
  ],
),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        final society = controller.society.value;
        if (society == null) {
          return _NoDataState(onRetry: controller.refresh);
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
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

void _showComingSoon(String feature) {
  AppSnackbar.info(
    feature,
    'Coming soon',
    
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
                Icons.home_work_outlined,
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
            const SizedBox(height: AppDimens.space8),
            Text(
              'Add a property to continue. You’ll join a society, enter property details, then see request status.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space24),

            // Only this primary action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.joinSociety),
                icon: const Icon(Icons.add_home_rounded, size: 20),
                label: const Text('Add property'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Optional cancel / dismiss
            TextButton(
              onPressed: () {
                // Stay on dashboard (or use Get.back() if this was opened on top)
                onRetry();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
    final now = DateTime.now();

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
                    // Top row: menu + society + actions
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.menu_rounded,
                              size: 20,
                              color: AppColors.textPrimary,
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
                        Flexible(
  child: Align(
    alignment: Alignment.centerLeft,
    child: _SocietyDropdown(
            societies: controller.societies,
            selected: society,
            onSelected: controller.selectSociety,
          )
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

                    // Greeting + date card
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
                                '${controller.userName.split(' ').first}.',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.accentGreenDark,
                                  fontSize: 38,
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
                        Builder(
                          builder: (context) {
                            final hour = DateTime.now().hour;
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

                            final fullDateStr =
                                DateFormat('d MMM yyyy, EEEE').format(now);

                            return Container(
                              width: 140,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusLg),
                                border:
                                    Border.all(color: AppColors.borderLight),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.03),
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
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
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
                                      Icon(timeIcon,
                                          size: 17, color: timeColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        timeLabel,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
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
                // Metrics — always Approved (user only reaches dashboard after approval)
                _MetricCardsRow(property: property),
                const SizedBox(height: 20),

                // Property hero + dropdown (same society only)
                _PropertyHeroCard(
                  property: property,
                  properties: controller.propertiesInCurrentSociety,
                  showDropdown: controller.hasMultiplePropertiesInSociety,
                  onPropertySelected: controller.selectProperty,
                ),
                const SizedBox(height: 20),

                const _QuickActionsCard(),
                const SizedBox(height: 20),

                _PropertyDetailsCard(property: property),
                const SizedBox(height: 20),

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
// Society dropdown (professional)
// ─────────────────────────────────────────────────────────────────────────────

class _SocietyDropdown extends StatelessWidget {
  final List<SocietyModel> societies;
  final SocietyModel selected;
  final ValueChanged<SocietyModel> onSelected;

  const _SocietyDropdown({
    required this.societies,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SocietyModel>(
      onSelected: onSelected,
      offset: const Offset(0, 40),
      elevation: 8,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      
        itemBuilder: (context) {
  return [
    PopupMenuItem<SocietyModel>(
      enabled: false,
      height: 36,
      child: Text(
        'SWITCH SOCIETY',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    const PopupMenuDivider(height: 1),
    ...societies.map((s) {
      final isSelected = s.id == selected.id;
      return PopupMenuItem<SocietyModel>(
        value: s,
        height: 56,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.pastelGreenBg.withValues(alpha: 0.55)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pastelGreenBg
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.home_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.accentGreenDark
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.accentGreenDark
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (s.city.isNotEmpty)
                      Text(
                        s.city,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreenDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    }),
    const PopupMenuDivider(height: 1),
    // Join Society action
    PopupMenuItem<SocietyModel>(
      height: 52,
      onTap: () {
        // delay so menu closes first
        Future.microtask(() {
          Get.toNamed(AppRoutes.joinSociety);
        });
      },
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.pastelBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_home_work_rounded,
              size: 18,
              color: AppColors.pastelBlueIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Join Society',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accentGreenDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    ),
  ];
},
      
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_rounded,
              size: 14,
              color: AppColors.accentGreenDark,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                selected.name.toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric cards — no documents, always Approved
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCardsRow extends StatelessWidget {
  final PropertyModel property;

  const _MetricCardsRow({required this.property});

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
            value: 'Yes',
            label: 'Owner\nStatus',
            subLabel: 'Approved',
            subColor: AppColors.successGreenDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.fact_check_rounded,
            iconBg: AppColors.pastelBlueBg,
            iconColor: AppColors.pastelBlueIcon,
            value: 'Yes',
            label: 'Property\nStatus',
            subLabel: 'Approved',
            subColor: AppColors.successGreenDark,
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
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18)),
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
// Property Hero + dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyHeroCard extends StatelessWidget {
  final PropertyModel property;
  final List<PropertyModel> properties;
  final bool showDropdown;
  final ValueChanged<PropertyModel>? onPropertySelected;

  const _PropertyHeroCard({
    required this.property,
    this.properties = const [],
    this.showDropdown = false,
    this.onPropertySelected,
  });

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
            child: showDropdown && properties.length > 1
                ? _PropertyDropdown(
                    selected: property,
                    properties: properties,
                    onSelected: onPropertySelected,
                  )
                : Column(
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
          InkWell(
  onTap: () => Get.toNamed(AppRoutes.manageProperties),
  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.pastelGreenBg,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      border: Border.all(
        color: AppColors.accentGreen.withValues(alpha: 0.25),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.edit_rounded,
          size: 14,
          color: AppColors.accentGreenDark,
        ),
        const SizedBox(width: 5),
        Text(
          'Edit',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.accentGreenDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  ),
),
        ],
      ),
    );
  }
}

class _PropertyDropdown extends StatelessWidget {
  final PropertyModel selected;
  final List<PropertyModel> properties;
  final ValueChanged<PropertyModel>? onSelected;
  final ValueChanged<PropertyModel>? onToggleOccupancy; // optional

  const _PropertyDropdown({
    required this.selected,
    required this.properties,
    this.onSelected,
    // ignore: unused_element_parameter
    this.onToggleOccupancy,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PropertyModel>(
      onSelected: onSelected,
      offset: const Offset(0, 52),
      elevation: 8,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<PropertyModel>(
            enabled: false,
            height: 36,
            child: Text(
              'SWITCH PROPERTY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          ...properties.map((p) {
            final isSelected = p.id == selected.id;
            return PopupMenuItem<PropertyModel>(
              value: p,
              height: 64,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.pastelGreenBg
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.home_rounded,
                      size: 20,
                      color: isSelected
                          ? AppColors.accentGreenDark
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Flat ${p.flatNumber}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.accentGreenDark
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.building} · ${p.floor}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Occupancy chip + edit icon
                  GestureDetector(
                    onTap: () {
                      // close menu, then toggle
                      Navigator.of(context).pop();
                      Future.microtask(() {
                        if (onToggleOccupancy != null) {
                          onToggleOccupancy!(p);
                        } else {
                          AppSnackbar.info(
                            'Occupancy',
                            p.isOccupied
                                ? 'Mark as Vacant — coming soon'
                                : 'Mark as Occupied — coming soon',
                          );
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.isOccupied
                            ? AppColors.pastelOrangeBg
                            : AppColors.pastelGreenBg,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.isOccupied ? 'Occupied' : 'Vacant',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: p.isOccupied
                                  ? AppColors.pastelOrangeIcon
                                  : AppColors.accentGreenDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_rounded,
                            size: 12,
                            color: p.isOccupied
                                ? AppColors.pastelOrangeIcon
                                : AppColors.accentGreenDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const PopupMenuDivider(height: 1),
          // Add Property action
          PopupMenuItem<PropertyModel>(
            height: 52,
            onTap: () {
              Future.microtask(() {
                Get.toNamed(AppRoutes.propertyDetails);
              });
            },
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_home_rounded,
                    size: 18,
                    color: AppColors.pastelBlueIcon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add Property',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accentGreenDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ];
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Flat ${selected.flatNumber}',
                  style: AppTextStyles.h4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.pastelGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.accentGreenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${selected.building} · ${selected.floor}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions — no documents
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.person_add_alt_1_rounded,
        'Add Tenant',
        AppColors.pastelGreenBg,
        AppColors.pastelGreenIcon,
        () => Get.toNamed(AppRoutes.addTenant),
      ),
      (
        Icons.badge_rounded,
        'Add Manager',
        AppColors.pastelBlueBg,
        AppColors.pastelBlueIcon,
        () => Get.toNamed(AppRoutes.addManager),
      ),
      (
        Icons.edit_rounded,
        'Edit Property',
        AppColors.pastelOrangeBg,
        AppColors.pastelOrangeIcon,
        () => Get.toNamed(AppRoutes.manageProperties),
      ),
      (
        Icons.sync_alt_rounded,
        'Transfer',
        AppColors.pastelPurpleBg,
        AppColors.pastelPurpleIcon,
        () => Get.toNamed(AppRoutes.manageProperties),
      ),
      (
        Icons.build_rounded,
        'Maintenance',
        AppColors.surfaceMuted,
        AppColors.textSecondary,
        () => _showComingSoon('Maintenance Request'),
      ),
      (
        Icons.support_agent_rounded,
        'Contact Admin',
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
          Text(
            'Quick Actions',
            style: AppTextStyles.h4.copyWith(fontSize: 16),
          ),
          
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: actions.map((a) {
              return InkWell(
                onTap: a.$5,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: a.$3,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.$1, size: 22, color: a.$4),
                      const SizedBox(height: 6),
                      Text(
                        a.$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: a.$4,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
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
// Latest Updates
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