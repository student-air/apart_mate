// lib/presentation/property_details/views/property_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/core/widgets/app_dropdown_field.dart';
import 'package:apart_mate/core/widgets/app_responsive_container.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/presentation/property_details/controllers/property_details_controller.dart';

class PropertyDetailsView extends StatefulWidget {
  const PropertyDetailsView({super.key});

  @override
  State<PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<PropertyDetailsView> {
  final PropertyDetailsController controller = Get.find<PropertyDetailsController>();
  final PageController _pageController = PageController();
  final RxInt currentStep = 0.obs;

  static const totalSteps = 3;

  void _goToStep(int step) {
    currentStep.value = step;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
  if (!controller.validateStep(currentStep.value)) return;

  if (currentStep.value < totalSteps - 1) {
    _goToStep(currentStep.value + 1);
  } else {
    controller.saveAndContinue();
  }
}

  void _back() {
    if (currentStep.value > 0) {
      _goToStep(currentStep.value - 1);
    } else {
      controller.goBack();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: _back, currentStep: currentStep, totalSteps: totalSteps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => currentStep.value = i,
              children: [
                _BasicInfoStep(controller: controller),
                _SpecificationsStep(controller: controller),
                _UtilitiesStep(controller: controller),
              ],
            ),
          ),
          _Footer(controller: controller, currentStep: currentStep, totalSteps: totalSteps, onNext: _next),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final RxInt currentStep;
  final int totalSteps;
  const _Header({required this.onBack, required this.currentStep, required this.totalSteps});

  static const stepTitles = ['Basic Information', 'Specifications', 'Utilities & Facilities'];

  @override
  Widget build(BuildContext context) {
    final role = Get.find<IAuthRepository>().currentUser?.role ?? '';
    final roleLabel = role.isEmpty ? '' : role[0].toUpperCase() + role.substring(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12, top: 2),
                    child: Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark, size: 22),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Property Details', style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark)),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          stepTitles[currentStep.value],
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnDarkMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                if (roleLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      roleLabel,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.space16),
            Obx(
              () => Row(
                children: List.generate(totalSteps, (i) {
                  final isActive = i <= currentStep.value;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accentGreen : AppColors.textOnDarkFaint,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a step's card so it's vertically centered in whatever space is
/// left between header and footer, and horizontally capped/centered on
/// larger screens via AppResponsiveContainer.
class _CenteredStep extends StatelessWidget {
  final Widget child;
  const _CenteredStep({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.space20,
            AppDimens.space20,
            AppDimens.space20,
            AppDimens.space24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - AppDimens.space48),
            child: Center(
              child: AppResponsiveContainer(child: child),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.overline),
          const SizedBox(height: AppDimens.space16),
          ...children,
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillOption({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelGreenBg : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && isSelected) ...[
              Icon(icon, size: 16, color: AppColors.successGreenDark),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.successGreenDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// STEP 1 — Basic Information
// ---------------------------------------------------------------------
class _BasicInfoStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _BasicInfoStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CenteredStep(
      child: _SectionCard(
        title: 'BASIC INFORMATION',
        children: [
          Obx(
            () => AppDropdownField<String?>(
              label: 'Building',
              value: controller.selectedBuilding.value,
              items: [null, ...PropertyDetailsController.buildings],
              labelBuilder: (v) => v ?? 'Select Building',
              onChanged: (v) => controller.selectedBuilding.value = v,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Obx(
            () => AppDropdownField<String?>(
              label: 'Floor',
              value: controller.selectedFloor.value,
              items: [null, ...PropertyDetailsController.floors],
              labelBuilder: (v) => v ?? 'Select Floor',
              onChanged: (v) => controller.selectedFloor.value = v,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          AppTextField(
            label: 'Flat Number',
            hint: 'e.g. A-203',
            controller: controller.flatNumberCtrl,
          ),
          const SizedBox(height: AppDimens.space20),
          Text('Occupied?', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppDimens.space8),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _PillOption(
                    label: 'Yes',
                    icon: Icons.check_circle_rounded,
                    isSelected: controller.isOccupied.value,
                    onTap: () => controller.isOccupied.value = true,
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: _PillOption(
                    label: 'No',
                    isSelected: !controller.isOccupied.value,
                    onTap: () => controller.isOccupied.value = false,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!controller.isOccupied.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.space20),
                Text('Occupied by', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimens.space8),
                Row(
                  children: [
                    Expanded(
                      child: _PillOption(
                        label: 'Owner',
                        isSelected: controller.occupiedBy.value == 'owner',
                        onTap: () => controller.occupiedBy.value = 'owner',
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: _PillOption(
                        label: 'Tenant',
                        isSelected: controller.occupiedBy.value == 'tenant',
                        onTap: () => controller.occupiedBy.value = 'tenant',
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// STEP 2 — Specifications
// ---------------------------------------------------------------------
class _SpecificationsStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _SpecificationsStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CenteredStep(
      child: _SectionCard(
        title: 'SPECIFICATIONS',
        children: [
          Obx(
            () => AppDropdownField<String?>(
              label: 'Property Type',
              value: controller.selectedPropertyType.value,
              items: [null, ...PropertyDetailsController.propertyTypes],
              labelBuilder: (v) => v ?? 'Apartment, House, Office...',
              onChanged: (v) => controller.selectedPropertyType.value = v,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Area (sq ft)',
                  hint: 'e.g. 1200',
                  controller: controller.areaCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: AppTextField(
                  label: 'Bathrooms',
                  hint: '0',
                  controller: controller.bathroomsCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                  () => AppDropdownField<String?>(
                    label: 'Flat Type',
                    value: controller.selectedFlatType.value,
                    items: [null, ...PropertyDetailsController.flatTypes],
                    labelBuilder: (v) => v ?? 'Select',
                    onChanged: (v) => controller.selectedFlatType.value = v,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balcony', style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppDimens.space6),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _PillOption(
                              label: 'Yes',
                              isSelected: controller.hasBalcony.value,
                              onTap: () => controller.hasBalcony.value = true,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space8),
                          Expanded(
                            child: _PillOption(
                              label: 'No',
                              isSelected: !controller.hasBalcony.value,
                              onTap: () => controller.hasBalcony.value = false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// STEP 3 — Utilities & Facilities
// ---------------------------------------------------------------------
class _UtilitiesStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _UtilitiesStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CenteredStep(
      child: _SectionCard(
        title: 'UTILITIES & FACILITIES',
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Electricity', style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppDimens.space6),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _PillOption(
                              label: 'Yes',
                              isSelected: controller.hasElectricity.value,
                              onTap: () => controller.hasElectricity.value = true,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space8),
                          Expanded(
                            child: _PillOption(
                              label: 'No',
                              isSelected: !controller.hasElectricity.value,
                              onTap: () => controller.hasElectricity.value = false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gas', style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppDimens.space6),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _PillOption(
                              label: 'Yes',
                              isSelected: controller.hasGas.value,
                              onTap: () => controller.hasGas.value = true,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space8),
                          Expanded(
                            child: _PillOption(
                              label: 'No',
                              isSelected: !controller.hasGas.value,
                              onTap: () => controller.hasGas.value = false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          Obx(
            () => AppDropdownField<String?>(
              label: 'Meter Type',
              value: controller.selectedMeterType.value,
              items: [null, ...PropertyDetailsController.meterTypes],
              labelBuilder: (v) => v ?? 'Wapda / Society',
              onChanged: (v) => controller.selectedMeterType.value = v,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Obx(
            () => AppDropdownField<String?>(
              label: 'Water Connection',
              value: controller.selectedWaterConnection.value,
              items: [null, ...PropertyDetailsController.waterConnectionTypes],
              labelBuilder: (v) => v ?? 'Select type',
              onChanged: (v) => controller.selectedWaterConnection.value = v,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Obx(
            () => AppDropdownField<String?>(
              label: 'Furnishing',
              value: controller.selectedFurnishing.value,
              items: [null, ...PropertyDetailsController.furnishingTypes],
              labelBuilder: (v) => v ?? 'Furnished / Semi / Unfurnished',
              onChanged: (v) => controller.selectedFurnishing.value = v,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final PropertyDetailsController controller;
  final RxInt currentStep;
  final int totalSteps;
  final VoidCallback onNext;

  const _Footer({
    required this.controller,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => AppPrimaryButton(
            label: currentStep.value == totalSteps - 1 ? 'Save & Continue' : 'Next',
            isLoading: controller.isLoading.value,
            onPressed: onNext,
          ),
        ),
      ),
    );
  }
}