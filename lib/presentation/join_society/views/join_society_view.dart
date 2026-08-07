// lib/presentation/join_society/views/join_society_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/presentation/join_society/controllers/join_society_controller.dart';

class JoinSocietyView extends GetView<JoinSocietyController> {
  const JoinSocietyView({super.key});

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
                AppDimens.space24,
                AppDimens.space20,
                AppDimens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Society Code', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppDimens.space16),
                  _CodeInputRow(controller: controller),
                  const SizedBox(height: AppDimens.space12),
                  Center(
                    child: Text(
                      'Enter the 6-character society code',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  Obx(() {
                    if (controller.isLookingUp.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
                      );
                    }
                    if (controller.society.value != null) {
                      return _SocietyPreviewCard(society: controller.society.value!);
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: AppDimens.space24),
                  Obx(
                    () => AppPrimaryButton(
                      label: 'Continue',
                      isLoading: controller.isJoining.value,
                      onPressed: controller.society.value != null ? controller.continueWithSociety : null,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  Center(
                    child: Text(
                      "Don't have a code? Contact your admin",
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
  final JoinSocietyController controller;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.goBack,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textOnDark, size: 22),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Join Society', style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark)),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the code provided by your society',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnDarkMuted),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
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
            child: const Icon(Icons.villa_rounded, size: 20, color: AppColors.primaryDark),
          );
        },
      ),
    );
  }
}

// class _LogoBadge extends StatelessWidget {
//   const _LogoBadge();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 36,
//       height: 36,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
//       child: Image.asset(
//         'assets/images/logo.png',
//         width: 36,
//         height: 36,
//         fit: BoxFit.contain,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppColors.accentGreen,
//               borderRadius: BorderRadius.circular(AppDimens.radiusSm),
//             ),
//             alignment: Alignment.center,
//             child: const Icon(Icons.apartment_rounded, size: 20, color: AppColors.primaryDark),
//           );
//         },
//       ),
//     );
//   }
// }
class _CodeInputRow extends StatelessWidget {
  final JoinSocietyController controller;
  const _CodeInputRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(JoinSocietyController.codeLength, (i) {
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
      width: 48,
      height: 56,
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
            UpperCaseTextFormatter(),
          ],
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              borderSide: const BorderSide(color: AppColors.accentGreenDark, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Forces every character typed into a code box to uppercase, so
/// join codes are case-insensitive from the user's perspective.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _SocietyPreviewCard extends StatelessWidget {
  final dynamic society; // SocietyModel
  const _SocietyPreviewCard({required this.society});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: const BorderRadius.only(
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
                  child: const Icon(Icons.villa_rounded, size: 24, color: AppColors.accentGreenDark),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(society.name as String, style: AppTextStyles.h4),
                      const SizedBox(height: 2),
                      Text(
                        '${society.address}, ${society.city}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (society.isVerified as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      'Verified',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.successGreenDark),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(value: '${society.buildingsCount}', label: 'Buildings'),
                _StatColumn(value: '${society.unitsCount}', label: 'Units'),
                _StatColumn(value: '${society.foundedYear}', label: 'Founded'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}