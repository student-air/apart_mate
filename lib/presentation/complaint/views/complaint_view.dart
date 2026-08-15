import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/presentation/complaint/controllers/complaint_controller.dart';

class ComplaintView extends GetView<ComplaintController> {
  const ComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
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
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.12),
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
                      'File Complaint',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Title',
                    hint: 'e.g. Water leakage in kitchen',
                    controller: controller.titleCtrl,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Description',
                    hint: 'Describe the issue',
                    controller: controller.descriptionCtrl,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  Text('Category', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 10),
                  Obx(() {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ComplaintController.categories.map((c) {
                        final selected =
                            controller.selectedCategory.value == c;
                        return GestureDetector(
                          onTap: () => controller.selectCategory(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.pastelGreenBg
                                  : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accentGreen
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              c,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: selected
                                    ? AppColors.successGreenDark
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  Text('Property', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.properties.isEmpty) {
                      return Text(
                        'No property found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      );
                    }
                    return Column(
                      children: controller.properties.map((p) {
                        final selected =
                            controller.selectedPropertyId.value == p.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => controller.selectProperty(p.id),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.pastelGreenBg
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.accentGreen
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                'Flat ${p.flatNumber} · ${p.building}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Submit Complaint',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}