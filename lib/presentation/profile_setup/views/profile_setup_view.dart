// lib/presentation/profile_setup/views/profile_setup_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/core/widgets/app_dropdown_field.dart';
import 'package:apart_mate/presentation/profile_setup/controllers/profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space32,
                AppDimens.space20,
                AppDimens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AvatarPicker(controller: controller),
                  const SizedBox(height: AppDimens.space32),
                  AppTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: controller.fullNameCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),
                  Obx(
                    () => AppDropdownField<String?>(
                      label: 'Gender',
                      value: controller.selectedGender.value,
                      items: [null, ...ProfileSetupController.genders],
                      labelBuilder: (g) => g ?? 'Select gender',
                      onChanged: (v) => controller.selectedGender.value = v,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space20),
                  AppTextField(
                    label: 'City',
                    hint: 'Enter your city',
                    controller: controller.cityCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),
                  AppTextField(
                    label: 'Occupation',
                    hint: 'e.g. Engineer, Doctor...',
                    controller: controller.occupationCtrl,
                  ),
                  const SizedBox(height: AppDimens.space20),
                  AppTextField(
                    label: 'Emergency Contact',
                    hint: '+92 300 0000000',
                    controller: controller.emergencyContactCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppDimens.space32),
                  Obx(
                    () => AppPrimaryButton(
                      label: 'Save & Continue',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.saveAndContinue,
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

class _Header extends StatelessWidget {
  final ProfileSetupController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.goBack,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: const Padding(
                padding: EdgeInsets.only(top: 4, right: 12),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark, size: 22),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Setup',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tell us about yourself',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnDarkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            _LogoBadge(),
          ],
        ),
      ),
    );
  }
}

/// Fixed-size logo tile. Falls back to a green icon badge if the asset is
/// missing or fails to load, so a bad asset path never breaks the header
/// layout (Flutter's default error widget ignores size constraints and
/// will otherwise blow up the whole row).
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: const Icon(Icons.apartment_rounded, size: 20, color: AppColors.primaryDark),
          );
        },
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final ProfileSetupController controller;
  const _AvatarPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                image: path != null
                    ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: path == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.pastelGreenIcon)
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
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: AppColors.surface, width: 2.5)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}