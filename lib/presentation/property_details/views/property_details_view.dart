// lib/presentation/property_details/views/property_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/core/widgets/app_dropdown_field.dart';
// import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
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
          _NewHeader(
            onBack: _back,
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
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
          _NewFooter(
            controller: controller,
            currentStep: currentStep,
            totalSteps: totalSteps,
            onNext: _next,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// HEADER
// ────────────────────────────────────────────────
class _NewHeader extends StatelessWidget {
  final VoidCallback onBack;
  final RxInt currentStep;
  final int totalSteps;

  const _NewHeader({
    required this.onBack,
    required this.currentStep,
    required this.totalSteps,
  });

  static const stepTitles = [
    'Basic Info',
    'Specifications',
    'Utilities',
  ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back button
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

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Details',
                        style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          stepTitles[currentStep.value],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textOnDarkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // App Logo (Right side)
                Container(
                  width: 46,
                  height: 46,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.villa_rounded,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.space20),

            // Step Indicator
            Obx(
              () => Row(
                children: List.generate(totalSteps, (i) {
                  final isActive = i == currentStep.value;
                  final isCompleted = i < currentStep.value;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isCompleted || isActive
                                      ? AppColors.accentGreen
                                      : AppColors.textOnDark.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check, size: 14, color: AppColors.primaryDark)
                                      : Text(
                                          '${i + 1}',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: isActive
                                                ? AppColors.primaryDark
                                                : AppColors.textOnDarkMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stepTitles[i],
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isActive
                                      ? AppColors.textOnDark
                                      : AppColors.textOnDarkMuted,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i != totalSteps - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.only(bottom: 22),
                              color: isCompleted
                                  ? AppColors.accentGreen
                                  : AppColors.textOnDark.withValues(alpha: 0.15),
                            ),
                          ),
                      ],
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
// ────────────────────────────────────────────────
// SHARED
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
        AppDimens.space12,
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

class _ModernPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _ModernPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelGreenBg : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : AppColors.border,
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && isSelected) ...[
              Icon(icon, size: 16, color: AppColors.successGreenDark),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.successGreenDark : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// STEP 1
// ────────────────────────────────────────────────
class _BasicInfoStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _BasicInfoStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.isIndependent) ...[
              AppTextField(
                label: 'House Name',
                hint: 'e.g. My Family House',
                controller: controller.flatNumberCtrl,
              ),
              const SizedBox(height: AppDimens.space16),
              AppTextField(
                label: 'Address',
                hint: 'Full house address',
                controller: controller.addressCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppDimens.space16),
              Obx(
                () => AppDropdownField<String?>(
                  label: 'House Type',
                  value: controller.selectedHouseType.value,
                  items: [null, ...PropertyDetailsController.houseTypes],
                  labelBuilder: (v) => v ?? 'Select House Type',
                  onChanged: (v) => controller.selectedHouseType.value = v,
                ),
              ),
            ] else ...[
              Obx(
                () => AppDropdownField<String?>(
                  label: 'Building',
                  value: controller.selectedBuilding.value,
                  items: [null, ...controller.buildingOptions],
                  labelBuilder: (v) => v ?? 'Select Building',
                  onChanged: (v) => controller.selectedBuilding.value = v,
                ),
              ),
              const SizedBox(height: AppDimens.space16),
              Obx(
                () => AppDropdownField<String?>(
                  label: 'Floor',
                  value: controller.selectedFloor.value,
                  items: [null, ...controller.floorOptions],
                  labelBuilder: (v) => v ?? 'Select Floor',
                  onChanged: (v) => controller.selectedFloor.value = v,
                ),
              ),
              const SizedBox(height: AppDimens.space16),
              AppTextField(
                label: 'Flat Number',
                hint: 'e.g. A-203',
                controller: controller.flatNumberCtrl,
              ),
            ],

            Text('Maintenance handled by', style: AppTextStyles.h4),
const SizedBox(height: 6),
Text(
  'Who recieive the mantenance expenses?',
  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
),
const SizedBox(height: 12),
Obx(() {
  return Row(
    children: [
      Expanded(
        child: _ModernPill( // or your existing pill widget
          label: 'Property Owner',
          icon: Icons.person_rounded,
          isSelected: controller.maintenanceBy.value == 'property_owner',
          onTap: () => controller.setMaintenanceBy('property_owner'),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _ModernPill(
          label: 'Society Admin',
          icon: Icons.home_rounded,
          isSelected: controller.maintenanceBy.value == 'society_admin',
          onTap: () => controller.setMaintenanceBy('society_admin'),
        ),
      ),
    ],
  );
}), 

Obx(() {
  if (controller.maintenanceBy.value != 'property_owner') {
    return const SizedBox.shrink();
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: AppDimens.space16),
      AppTextField(
        label: 'Monthly maintenance (Rs.)',
        hint: 'e.g. 5000',
        controller: controller.maintenanceAmountCtrl,
        keyboardType: TextInputType.number,
      ),
    ],
  );
}),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// STEP 2
// ────────────────────────────────────────────────
class _SpecificationsStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _SpecificationsStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => AppDropdownField<String?>(
                label: 'Property Type',
                value: controller.selectedPropertyType.value,
                items: [null, ...PropertyDetailsController.propertyTypes],
                labelBuilder: (v) => v ?? 'Select type',
                onChanged: (v) => controller.selectedPropertyType.value = v,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Area (sq ft)',
                    hint: '1200',
                    controller: controller.areaCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: AppTextField(
                    label: 'Bathrooms',
                    hint: '2',
                    controller: controller.bathroomsCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space16),
            Obx(
              () => AppDropdownField<String?>(
                label: controller.isIndependent ? 'Rooms' : 'Flat Type',
                value: controller.selectedFlatType.value,
                items: [null, ...PropertyDetailsController.flatTypes],
                labelBuilder: (v) => v ?? 'Select',
                onChanged: (v) => controller.selectedFlatType.value = v,
              ),
            ),
            const SizedBox(height: AppDimens.space20),
            Text('Balcony', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppDimens.space12),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _ModernPill(
                      label: 'Yes',
                      isSelected: controller.hasBalcony.value,
                      onTap: () => controller.hasBalcony.value = true,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: _ModernPill(
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
    );
  }
}

// ────────────────────────────────────────────────
// STEP 3
// ────────────────────────────────────────────────
class _UtilitiesStep extends StatelessWidget {
  final PropertyDetailsController controller;
  const _UtilitiesStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Electricity', style: AppTextStyles.labelLarge),
                      const SizedBox(height: AppDimens.space8),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: _ModernPill(
                                label: 'Yes',
                                isSelected: controller.hasElectricity.value,
                                onTap: () => controller.hasElectricity.value = true,
                              ),
                            ),
                            const SizedBox(width: AppDimens.space8),
                            Expanded(
                              child: _ModernPill(
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
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gas', style: AppTextStyles.labelLarge),
                      const SizedBox(height: AppDimens.space8),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: _ModernPill(
                                label: 'Yes',
                                isSelected: controller.hasGas.value,
                                onTap: () => controller.hasGas.value = true,
                              ),
                            ),
                            const SizedBox(width: AppDimens.space8),
                            Expanded(
                              child: _ModernPill(
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
                labelBuilder: (v) => v ?? 'Select',
                onChanged: (v) => controller.selectedMeterType.value = v,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Obx(
              () => AppDropdownField<String?>(
                label: 'Water Connection',
                value: controller.selectedWaterConnection.value,
                items: [null, ...PropertyDetailsController.waterConnectionTypes],
                labelBuilder: (v) => v ?? 'Select type',
                onChanged: (v) => controller.selectedWaterConnection.value = v,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Obx(
              () => AppDropdownField<String?>(
                label: 'Furnishing',
                value: controller.selectedFurnishing.value,
                items: [null, ...PropertyDetailsController.furnishingTypes],
                labelBuilder: (v) => v ?? 'Select',
                onChanged: (v) => controller.selectedFurnishing.value = v,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// FOOTER
// ────────────────────────────────────────────────
class _NewFooter extends StatelessWidget {
  final PropertyDetailsController controller;
  final RxInt currentStep;
  final int totalSteps;
  final VoidCallback onNext;

  const _NewFooter({
    required this.controller,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => AppPrimaryButton(
            label: currentStep.value == totalSteps - 1 ? 'Save & Continue' : 'Continue',
            isLoading: controller.isLoading.value,
            onPressed: onNext,
          ),
        ),
      ),
    );
  }
}