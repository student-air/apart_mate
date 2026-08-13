// lib/presentation/tenant_confirm/views/tenant_confirm_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/presentation/tenant_confirm/controllers/tenant_confirm_controller.dart';

class TenantConfirmView extends GetView<TenantConfirmController> {
  const TenantConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = controller.tenant;
    final p = controller.property;
    final initial =
        t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?';

    final typeLine = [
      if (p.propertyType.isNotEmpty) p.propertyType,
      if (p.flatType.isNotEmpty) p.flatType,
    ].join(' · ');

    return Scaffold(
  backgroundColor: AppColors.background,
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  floatingActionButton: _ExpandableReportFab(
    onAction: controller.reportWrongDetails,
  ),
   body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppDimens.headerRadius),
                bottomRight: Radius.circular(AppDimens.headerRadius),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.goBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            AppColors.textOnDark.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textOnDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirm',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.villa_rounded,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identity hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
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
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.pastelGreenBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentGreen
                                  .withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.accentGreenDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          t.fullName,
                          style: AppTextStyles.h3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
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
                                size: 14,
                                color: AppColors.accentGreenDark,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Tenant',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accentGreenDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Confirm these details and continue to dashboard.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact details
                  _SectionCard(
  icon: Icons.key_rounded,
  iconBg: AppColors.pastelBlueBg,
  iconColor: AppColors.pastelBlueIcon,
  title: 'Your information',
  children: [
    _InfoTile(
      icon: Icons.person_outline_rounded,
      label: 'Full name',
      value: t.fullName,
    ),
    _InfoTile(
      icon: Icons.phone_outlined,
      label: 'Phone',
      value: t.phone,
    ),
    _InfoTile(
      icon: Icons.credit_card_outlined,
      label: 'CNIC',
      value: t.cnic,
      isLast: true,
    ),
  ],
),
const SizedBox(height: 14),

// ── 2. Property — two columns ───────────────────────────────
_SectionCard(
  icon: Icons.home_work_rounded,
  iconBg: AppColors.pastelGreenBg,
  iconColor: AppColors.pastelGreenIcon,
  title: 'Property you’re renting',
  children: [
    // Flat hero
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.home_rounded,
              size: 22,
              color: AppColors.pastelGreenIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flat ${p.flatNumber}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (p.building.isNotEmpty) p.building,
                    if (p.floor.isNotEmpty) p.floor,
                  ].join(' · ').ifEmpty('—'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: p.isOccupied
                  ? AppColors.pastelOrangeBg
                  : AppColors.pastelGreenBg,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              p.isOccupied ? 'Occupied' : 'Vacant',
              style: AppTextStyles.labelSmall.copyWith(
                color: p.isOccupied
                    ? AppColors.pastelOrangeIcon
                    : AppColors.accentGreenDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),

    // Two-column grid
    _TwoCol(
      left: _MiniInfo(
        label: 'Building',
        value: p.building.isEmpty ? '—' : p.building,
      ),
      right: _MiniInfo(
        label: 'Floor',
        value: p.floor.isEmpty ? '—' : p.floor,
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Flat number',
        value: p.flatNumber.isEmpty ? '—' : p.flatNumber,
      ),
      right: _MiniInfo(
        label: 'Property type',
        value: p.propertyType.isEmpty ? '—' : p.propertyType,
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Flat type',
        value: p.flatType.isEmpty ? '—' : p.flatType,
      ),
      right: _MiniInfo(
        label: 'Area',
        value: p.areaSqFt.isEmpty ? '—' : '${p.areaSqFt} sq ft',
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Bathrooms',
        value: p.bathrooms.isEmpty ? '—' : p.bathrooms,
      ),
      right: _MiniInfo(
        label: 'Balcony',
        value: p.hasBalcony ? 'Yes' : 'No',
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Electricity',
        value: p.hasElectricity ? 'Available' : 'Not available',
      ),
      right: _MiniInfo(
        label: 'Meter type',
        value: p.meterType.isEmpty ? '—' : p.meterType,
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Gas',
        value: p.hasGas ? 'Available' : 'Not available',
      ),
      right: _MiniInfo(
        label: 'Water',
        value: p.waterConnection.isEmpty ? '—' : p.waterConnection,
      ),
    ),
    _TwoCol(
      left: _MiniInfo(
        label: 'Furnishing',
        value: p.furnishing.isEmpty ? '—' : p.furnishing,
      ),
      right: const SizedBox.shrink(), // empty second cell if odd
    ),
  ],
),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ────────────────────────────────────────────────
          Container(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    border: const Border(
      top: BorderSide(color: AppColors.borderLight),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: SafeArea(
    top: false,
    child: Column(
      children: [
        // Agreement checkbox
        Obx(() {
          return InkWell(
            onTap: () => controller.toggleAgreement(
              !controller.agreedToDetails.value,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.agreedToDetails.value
                      ? AppColors.accentGreen.withValues(alpha: 0.45)
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: controller.agreedToDetails.value,
                      onChanged: controller.toggleAgreement,
                      activeColor: AppColors.accentGreenDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Yes, I confirm these details are correct',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Obx(
          () => Opacity(
            opacity: controller.agreedToDetails.value ? 1 : 0.45,
            child: AppPrimaryButton(
              label: 'Continue to dashboard',
              isLoading: controller.isLoading.value,
              onPressed: controller.agreedToDetails.value
                  ? controller.continueToDashboard
                  : null, // disabled until checked
            ),
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



extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.children,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.h4.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
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

class _TwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExpandableReportFab extends StatefulWidget {
  final VoidCallback onAction;

  const _ExpandableReportFab({required this.onAction});

  @override
  State<_ExpandableReportFab> createState() => _ExpandableReportFabState();
}

class _ExpandableReportFabState extends State<_ExpandableReportFab>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    _scheduleCollapse();
  }

  void _scheduleCollapse() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _expanded) {
        setState(() => _expanded = false);
      }
    });
  }

  void _onTap() {
    if (!_expanded) {
      // First tap → expand only
      setState(() => _expanded = true);
      _scheduleCollapse();
      return;
    }
    // Already expanded → run action
    widget.onAction();
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 88),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          height: 56,
          padding: EdgeInsets.symmetric(
            horizontal: _expanded ? 18 : 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: AppColors.danger,
                size: 22,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Report issue',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}