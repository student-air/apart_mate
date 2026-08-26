// lib/presentation/join_society/views/join_society_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/data/models/society_model.dart';
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
                  // ── Society Code Header ──────────────────────────────
                  Text(
                    'Society Code',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask your society admin for the 6-character code',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space20),

                  // Code Input
                  _CodeInputRow(controller: controller),

                  const SizedBox(height: AppDimens.space12),

                  // Helper / Error text
                  Center(
                    child: Obx(() {
                      if (controller.lookupFailed.value) {
                        return Text(
                          'Invalid society code. Please try again',
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

                  // Society Preview
                  Obx(() {
                    if (controller.isLookingUp.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryDark),
                        ),
                      );
                    }
                    if (controller.society.value != null) {
                      return _SocietyPreviewCard(society: controller.society.value!);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: AppDimens.space24),

                  // Continue Button
                  Obx(
                    () => AppPrimaryButton(
                      label: 'Continue',
                      isLoading: controller.isJoining.value,
                      onPressed: controller.society.value != null
                          ? controller.continueWithSociety
                          : null,
                    ),
                  ),

                  const SizedBox(height: AppDimens.space28),

                  // ── Independent Owner Section ────────────────────────
                  Builder(
                    builder: (context) {
                      final role = controller.currentUserRole;

                      if (role != 'owner') {
                        return Center(
                          child: Text(
                            "Don't have a code? Contact your admin",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // OR Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.border, thickness: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.border, thickness: 1),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimens.space20),

                          // Independent Property Card
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.continueAsIndependentOwner,
                              borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppDimens.space20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppColors.pastelBlueBg,
                                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.home_work_rounded,
                                        size: 26,
                                        color: AppColors.pastelBlueIcon,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.space16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Independent Property',
                                            style: AppTextStyles.h4.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'I own a house without any society management',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                      Text(
                        'Join Society',
                        style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the code provided by your society',
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
            UpperCaseTextFormatter(),
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
  final SocietyModel society;
  const _SocietyPreviewCard({required this.society});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.pastelGreenBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.villa_rounded,
                  size: 24,
                  color: AppColors.accentGreenDark,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Text(society.name, style: AppTextStyles.h4),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          if (society.ownerName.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'Owner',
              value: society.ownerName,
            ),
            const SizedBox(height: AppDimens.space10),
          ],
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: society.fullAddress,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

