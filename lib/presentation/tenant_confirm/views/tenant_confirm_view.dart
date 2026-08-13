import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/presentation/tenant_confirm/controllers/tenant_confirm_controller.dart';

class TenantConfirmView extends GetView<TenantConfirmController> {
  const TenantConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = controller.tenant;
    final p = controller.property;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: controller.goBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Confirm your details', style: AppTextStyles.h3),
                  const SizedBox(height: 6),
                  Text(
                    'These details were shared by your landlord. Continue if they look correct.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tenant info
                  _Card(
                    title: 'Your information',
                    children: [
                      _Row(label: 'Full name', value: t.fullName),
                      _Row(label: 'Phone', value: t.phone),
                      _Row(label: 'CNIC', value: t.cnic, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Property info (from owner selection)
                  _Card(
                    title: 'Property you’re renting',
                    children: [
                      _Row(label: 'Flat', value: p.flatNumber),
                      _Row(label: 'Building', value: p.building),
                      _Row(label: 'Floor', value: p.floor.isEmpty ? '—' : p.floor),
                      _Row(
                        label: 'Type',
                        value: [
                          if (p.propertyType.isNotEmpty) p.propertyType,
                          if (p.flatType.isNotEmpty) p.flatType,
                        ].join(' · ').ifEmpty('—'),
                      ),
                      _Row(
                        label: 'Area',
                        value: p.areaSqFt.isEmpty ? '—' : '${p.areaSqFt} sq ft',
                        isLast: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Continue to dashboard',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.continueToDashboard,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirm',
                style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _Row({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}