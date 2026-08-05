import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_animations.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_card.dart';
import 'package:apart_mate/core/widgets/app_social_pill_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/presentation/auth/controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimens.headerRadius),
                    bottomRight: Radius.circular(AppDimens.headerRadius),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(AppStrings.createAccount, style: AppTextStyles.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.signUpSubtitle,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Obx(
                    () => AppShakeOnTrigger(
                      trigger: controller.signupShakeTrigger.value,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: AppStrings.fullName,
                              hint: AppStrings.fullNameHint,
                              controller: controller.fullNameCtrl,
                            ),
                            const SizedBox(height: AppDimens.space16),
                            AppTextField(
                              label: AppStrings.email,
                              hint: AppStrings.emailHint,
                              controller: controller.emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            Obx(() {
                              final error = controller.emailError.value;
                              if (error == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: AppDimens.space8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                                    const SizedBox(width: AppDimens.space4),
                                    Expanded(
                                      child: Text(
                                        error,
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: AppDimens.space16),
                            AppTextField(
                              label: AppStrings.phoneNumber,
                              hint: AppStrings.phoneHint,
                              controller: controller.phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            Obx(() {
                              final error = controller.phoneError.value;
                              if (error == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: AppDimens.space8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                                    const SizedBox(width: AppDimens.space4),
                                    Expanded(
                                      child: Text(
                                        error,
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: AppDimens.space16),
                            Obx(
                              () => AppTextField(
                                label: AppStrings.password,
                                hint: AppStrings.createPasswordHint,
                                controller: controller.signupPasswordCtrl,
                                obscureText: !controller.isSignupPasswordVisible.value,
                                suffixIcon: IconButton(
                                  onPressed: controller.toggleSignupPasswordVisibility,
                                  icon: Icon(
                                    controller.isSignupPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.space16),
                            Obx(
                              () => AppTextField(
                                label: AppStrings.confirmPassword,
                                hint: AppStrings.confirmPasswordHint,
                                controller: controller.confirmPasswordCtrl,
                                obscureText: !controller.isConfirmPasswordVisible.value,
                                suffixIcon: IconButton(
                                  onPressed: controller.toggleConfirmPasswordVisibility,
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.space24),
                            Obx(
                              () => AppPrimaryButton(
                                label: AppStrings.register,
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                isLoading: controller.isLoading.value,
                                onPressed: controller.signUp,
                              ),
                            ),
                            const SizedBox(height: AppDimens.space24),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(AppStrings.or, style: AppTextStyles.bodySmall),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: AppDimens.space20),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSocialPillButton(
                                    icon: Text(
                                      'G',
                                      style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF4285F4)),
                                    ),
                                    label: 'Google',
                                    onPressed: controller.signUpWithGoogle,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.space12),
                                Expanded(
                                  child: AppSocialPillButton(
                                    icon: const Icon(Icons.apple, size: 20, color: Colors.white),
                                    label: 'Apple',
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    borderColor: Colors.black,
                                    onPressed: controller.signUpWithApple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.alreadyHaveAccount, style: AppTextStyles.caption),
                  GestureDetector(
                    onTap: controller.goToLogin,
                    child: Text(AppStrings.login, style: AppTextStyles.labelLarge),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),
      ),
    );
  }
}