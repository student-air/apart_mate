import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_dropdown_field.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/presentation/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (Updates / Profile Setup style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space20,
              AppDimens.space12,
              AppDimens.space20,
              AppDimens.space20,
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
                    onTap: controller.goBack,
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
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Text(
                      'Edit Profile',
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space24,
                AppDimens.space20,
                AppDimens.space32,
              ),
              child: Column(
                children: [
                  // Avatar
                  Obx(() {
                    final path = controller.photoPath.value;
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.pastelGreenBg,
                              shape: BoxShape.circle,
                              image: path != null && path.isNotEmpty
                                  ? DecorationImage(
                                      image: FileImage(File(path)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: path == null || path.isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: AppColors.pastelGreenIcon,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: controller.pickPhoto,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 2.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimens.space32),

                  AppTextField(
                    label: 'Full Name',
                    hint: AppStrings.fullNameHint,
                    controller: controller.fullNameCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),

                  AppTextField(
                    label: 'Phone',
                    hint: AppStrings.phoneHint,
                    controller: controller.phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppDimens.space20),

                  AppTextField(
                    label: 'Email',
                    hint: AppStrings.emailHint,
                    controller: controller.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppDimens.space20),

                  Obx(
                    () => AppDropdownField<String?>(
                      label: 'Gender',
                      value: controller.selectedGender.value,
                      items: [null, ...EditProfileController.genders],
                      labelBuilder: (g) => g ?? 'Select gender',
                      onChanged: (v) =>
                          controller.selectedGender.value = v,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space20),

                  AppTextField(
                    label: 'City',
                    hint: AppStrings.cityHint,
                    controller: controller.cityCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),

                  AppTextField(
                    label: 'Occupation',
                    hint: AppStrings.occupationHint,
                    controller: controller.occupationCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),

                  AppTextField(
                    label: 'Emergency Contact',
                    hint: AppStrings.phoneHint,
                    controller: controller.emergencyContactCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppDimens.space32),

                  Obx(
                    () => AppPrimaryButton(
                      label: 'Save Changes',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.saveChanges,
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