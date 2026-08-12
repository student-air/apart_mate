import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/presentation/add_manager/controllers/add_manager_controller.dart';

class AddManagerView extends GetView<AddManagerController> {
  const AddManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Get.back()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // ── Manager details ──────────────────────────
                  _ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.managerDetails,
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.managerDetailsSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: controller.fullNameCtrl,
                          label: AppStrings.fullName,
                          hint: AppStrings.fullNameHint,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: controller.phoneCtrl,
                          label: 'Phone',
                          hint: AppStrings.phoneHint,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: controller.cnicCtrl,
                          label: AppStrings.cnic,
                          hint: AppStrings.cnicHint,
                        ),
                      ],
                    ),
                  ),

                  // ── Select all + grouped properties ──────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Assign Properties',
                            style: AppTextStyles.h4,
                          ),
                        ),
                        Obx(() {
                          final selected = controller.allSelected;
                          return TextButton(
                            onPressed: controller.allProperties.isEmpty
                                ? null
                                : controller.toggleSelectAll,
                            child: Text(
                              selected ? 'Deselect all' : 'Select all',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accentGreenDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All societies and independent properties',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  Obx(() {
                    final groups = controller.propertyGroups;
                    if (groups.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: _ModernCard(
                          child: Center(
                            child: Text(
                              'No properties available',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: groups.map((group) {
                        return _SocietyGroupCard(
                          group: group,
                          isGroupSelected:
                              controller.isGroupFullySelected(group),
                          onToggleGroup: () =>
                              controller.selectGroup(group),
                          isPropertySelected: controller.isSelected,
                          onToggleProperty: controller.toggleProperty,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          _Footer(
            isLoading: controller.isLoading,
            onSave: controller.saveManager,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Society / Independent group card
// ────────────────────────────────────────────────
class _SocietyGroupCard extends StatelessWidget {
  final PropertyGroup group;
  final bool isGroupSelected;
  final VoidCallback onToggleGroup;
  final bool Function(String id) isPropertySelected;
  final void Function(String id) onToggleProperty;

  const _SocietyGroupCard({
    required this.group,
    required this.isGroupSelected,
    required this.onToggleGroup,
    required this.isPropertySelected,
    required this.onToggleProperty,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header (select whole society)
          GestureDetector(
            onTap: onToggleGroup,
            child: Row(
              children: [
                Icon(
                  isGroupSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 22,
                  color: isGroupSelected
                      ? AppColors.accentGreenDark
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.title,
                    style: AppTextStyles.h4.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  '${group.properties.length} unit${group.properties.length == 1 ? '' : 's'}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          ...group.properties.map((p) {
            final selected = isPropertySelected(p.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PropertyRow(
                property: p,
                selected: selected,
                onTap: () => onToggleProperty(p.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final PropertyModel property;
  final bool selected;
  final VoidCallback onTap;

  const _PropertyRow({
    required this.property,
    required this.selected,
    required this.onTap,
  });

  String get _subtitle {
    final floor =
        property.floor.isEmpty ? '' : ' · ${property.floor}';
    final status = property.isOccupied ? ' · Occupied' : ' · Vacant';
    if (property.societyId.isEmpty) {
      final type = property.building.isEmpty
          ? 'Independent'
          : property.building;
      return '$type$status';
    }
    return '${property.building}$floor$status';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.pastelGreenBg : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accentGreen : AppColors.border,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 22,
              color: selected
                  ? AppColors.accentGreenDark
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flat ${property.flatNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.successGreenDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
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
    );
  }
}

// ────────────────────────────────────────────────
// HEADER
// ────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space12,
        AppDimens.space20,
        AppDimens.space24,
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
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textOnDark,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.addManager,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.addManagerSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                ],
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
    );
  }
}

// ────────────────────────────────────────────────
// CARD
// ────────────────────────────────────────────────
class _ModernCard extends StatelessWidget {
  final Widget child;
  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space20,
        AppDimens.space20,
        0,
      ),
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ────────────────────────────────────────────────
// FOOTER
// ────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final RxBool isLoading;
  final VoidCallback onSave;

  const _Footer({
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => AppPrimaryButton(
            label: AppStrings.saveManager,
            isLoading: isLoading.value,
            onPressed: onSave,
          ),
        ),
      ),
    );
  }
}