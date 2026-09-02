// lib/presentation/employee_join_code/views/employee_join_code_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/presentation/employee_join_code/controllers/employee_join_code_controller.dart';

class EmployeeJoinCodeView extends GetView<EmployeeJoinCodeController> {
  const EmployeeJoinCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: controller.goBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space24,
                AppDimens.space20,
                AppDimens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join code',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-character society code from the admin, '
                    'or the manager invite code from a property owner',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space20),

                  _CodeInputRow(controller: controller),

                  const SizedBox(height: AppDimens.space12),

                  Center(
                    child: Obx(() {
                      if (controller.lookupFailed.value) {
                        return Text(
                          'Invalid code. Please check and try again',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return Text(
                        'Letters and numbers only • Case insensitive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppDimens.space24),

                  Obx(() {
                    if (controller.isLookingUp.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimens.space24,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  Obx(
                    () => AppPrimaryButton(
                      label: 'Continue',
                      isLoading: controller.isContinuing.value ||
                          controller.isLookingUp.value,
                      onPressed: controller.continueWithCode,
                    ),
                  ),

                  const SizedBox(height: AppDimens.space28),

                  Center(
                    child: Text(
                      "Don't have a code? Contact your society admin or owner",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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

// ── Header (same language as Join Society) ────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textOnDark,
                  size: 22,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee join',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Society code or manager invite',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                const _LogoBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
            child: Text(
              'AM',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Code boxes ────────────────────────────────────────────────────────────

class _CodeInputRow extends StatelessWidget {
  final EmployeeJoinCodeController controller;
  const _CodeInputRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        EmployeeJoinCodeController.codeLength,
        (i) {
          return SizedBox(
            width: 48,
            height: 56,
            child: TextField(
              controller: controller.digitCtrls[i],
              focusNode: controller.focusNodes[i],
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.accentGreen,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) => controller.onDigitChanged(i, v),
              onTap: () {
                controller.digitCtrls[i].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.digitCtrls[i].text.length,
                );
              },
            ),
          );
        },
      ),
    );
  }
}