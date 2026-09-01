import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';

void showPrivacySecuritySheet() {
  Get.bottomSheet(
    const PrivacySecuritySheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class PrivacySecuritySheet extends StatefulWidget {
  const PrivacySecuritySheet({super.key});

  @override
  State<PrivacySecuritySheet> createState() => _PrivacySecuritySheetState();
}

class _PrivacySecuritySheetState extends State<PrivacySecuritySheet> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Privacy & Security', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Password and account security',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fingerprint_rounded,
                              color: AppColors.primaryDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Biometric login',
                                style: AppTextStyles.labelLarge),
                          ),
                          Obx(() => Switch.adaptive(
                                value: c.biometricLoginEnabled.value,
                                activeColor: AppColors.accentGreen,
                                onChanged: c.toggleBiometricLogin,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Change password',
                                  style: AppTextStyles.labelLarge),
                              const Spacer(),
                              TextButton(
                                onPressed: c.sendPasswordResetLink,
                                child: Text(
                                  'Forgot?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppTextField(
                            label: 'Current password',
                            controller: c.currentPasswordCtrl,
                            obscureText: !_showCurrent,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _showCurrent = !_showCurrent),
                              icon: Icon(
                                _showCurrent
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'New password',
                            controller: c.newPasswordCtrl,
                            obscureText: !_showNew,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _showNew = !_showNew),
                              icon: Icon(
                                _showNew
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Confirm new password',
                            controller: c.confirmPasswordCtrl,
                            obscureText: !_showConfirm,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _showConfirm = !_showConfirm),
                              icon: Icon(
                                _showConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(() => SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: c.isChangingPassword.value
                                      ? null
                                      : c.changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimens.radiusFull),
                                    ),
                                  ),
                                  child: c.isChangingPassword.value
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Update password',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                            color: AppColors.accentGreen,
                                          ),
                                        ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}