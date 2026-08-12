// lib/presentation/add_tenant/views/add_tenant_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/presentation/add_tenant/controllers/add_tenant_controller.dart';

class AddTenantView extends GetView<AddTenantController> {
  const AddTenantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header (same style as Property Details) ────────────────
          _Header(onBack: () => Get.back()),

          // ── Body ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final vacant = controller.vacantProperties;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    // Tenant details card
                    _ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tenant Details', style: AppTextStyles.h4),
                          const SizedBox(height: 6),
                          Text(
                            'Enter the tenant’s basic information',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          AppTextField(
  controller: controller.fullNameCtrl,
  label: 'Full Name',
  hint: AppStrings.fullNameHint,
),
const SizedBox(height: 14),
AppTextField(
  controller: controller.phoneCtrl,
  label: 'Phone',
  hint: AppStrings.phoneHint,
  keyboardType: TextInputType.phone,
),
const SizedBox(height: 14),
AppTextField(
  controller: controller.cnicCtrl,
  label: 'CNIC',
  hint: AppStrings.cnicHint,
),
                        ],
                      ),
                    ),

                    // Vacant properties card
                    _ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Vacant Property', style: AppTextStyles.h4),
                          const SizedBox(height: 6),
                          Text(
                            'Only vacant properties are shown',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (vacant.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'No vacant properties available',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            )
                          else
                            ...vacant.map((p) {
                              final selected =
                                  controller.selectedPropertyId.value == p.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => controller.selectProperty(p.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.pastelGreenBg
                                          : AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.accentGreen
                                            : AppColors.border,
                                        width: selected ? 1.6 : 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          selected
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          size: 22,
                                          color: selected
                                              ? AppColors.accentGreenDark
                                              : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Flat ${p.flatNumber}',
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: selected
                                                      ? AppColors
                                                          .successGreenDark
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${p.building} · ${p.floor}',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // ── Footer (same style as Property Details) ────────────────
          _Footer(
            isLoading: controller.isLoading,
            onSave: controller.saveTenant,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// HEADER
// ────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Tenant',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Invite a tenant to your property',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Logo
            SizedBox(
              width: 46,
              height: 46,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
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
    );
  }
}

// ────────────────────────────────────────────────
// CARD
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
        0,
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

// ────────────────────────────────────────────────
// FOOTER
// ────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final RxBool isLoading;
  final VoidCallback onSave;

  const _Footer({
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => AppPrimaryButton(
            label: 'Save Tenant',
            isLoading: isLoading.value,
            onPressed: onSave,
          ),
        ),
      ),
    );
  }
}