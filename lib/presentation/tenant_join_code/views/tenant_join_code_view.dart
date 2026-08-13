import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/presentation/tenant_join_code/controllers/tenant_join_code_controller.dart';

class TenantJoinCodeView extends GetView<TenantJoinCodeController> {
  const TenantJoinCodeView({super.key});

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
                    'Tenant Invite Code',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask your landlord for the 6-character code',
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
                          'Invalid invite code. Please try again',
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
                        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    }
                    if (controller.tenant.value != null &&
                        controller.property.value != null) {
                      return _InvitePreviewCard(
                        tenant: controller.tenant.value!,
                        property: controller.property.value!,
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: AppDimens.space24),

                  Obx(
                    () => AppPrimaryButton(
                      label: 'Continue',
                      isLoading: controller.isContinuing.value,
                      onPressed: controller.tenant.value != null
                          ? controller.continueWithInvite
                          : null,
                    ),
                  ),

                  const SizedBox(height: AppDimens.space28),

                  Center(
                    child: Text(
                      "Don't have a code? Contact your landlord",
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

// ── Header (same structure as Join Society) ───────────────────
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
                        'Join as Tenant',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the code provided by your landlord',
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
        errorBuilder: (_, __, ___) => Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.villa_rounded,
            size: 20,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// ── 6 code boxes (same as Join Society) ───────────────────────
class _CodeInputRow extends StatelessWidget {
  final TenantJoinCodeController controller;
  const _CodeInputRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(TenantJoinCodeController.codeLength, (i) {
        return _CodeBox(
          controller: controller.digitCtrls[i],
          focusNode: controller.focusNodes[i],
          onChanged: (v) => controller.onDigitChanged(i, v),
          onBackspace: () => controller.onBackspace(i),
        );
      }),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 58,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            _UpperCaseTextFormatter(),
          ],
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentGreen,
                width: 1.6,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentGreen,
                width: 1.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentGreenDark,
                width: 2.2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// ── Preview after valid code (like society preview) ───────────
class _InvitePreviewCard extends StatelessWidget {
  final TenantModel tenant;
  final PropertyModel property;

  const _InvitePreviewCard({
    required this.tenant,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: const BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius2xl),
                topRight: Radius.circular(AppDimens.radius2xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.home_rounded,
                    size: 24,
                    color: AppColors.accentGreenDark,
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flat ${property.flatNumber}',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${property.building} · ${property.floor}',
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
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Text(
                    tenant.fullName.isNotEmpty
                        ? tenant.fullName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        tenant.phone,
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
        ],
      ),
    );
  }
}