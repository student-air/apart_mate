import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/presentation/maintenance/controllers/maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                    onTap: () => Get.back(),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maintenance',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.isTenant
                              ? 'Your maintenance requests'
                              : 'Property complaints & requests',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textOnDarkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.build_rounded,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Obx(() {
              return Row(
                children: [
                  _tab('All', 0),
                  const SizedBox(width: 8),
                  _tab('Open', 1),
                  const SizedBox(width: 8),
                  _tab('Resolved', 2),
                ],
              );
            }),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.filtered;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No maintenance items yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return _ComplaintCard(
                      title: c.title,
                      subtitle: c.propertyLabel,
                      status: c.status,
                      category: c.category,
                      isOwner: !controller.isTenant,
                      onReviewed: () =>
                          controller.updateStatus(c, 'reviewed'),
                      onResolved: () =>
                          controller.updateStatus(c, 'resolved'),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.pastelGreenBg : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accentGreen : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected
                  ? AppColors.successGreenDark
                  : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String category;
  final bool isOwner;
  final VoidCallback onReviewed;
  final VoidCallback onResolved;

  const _ComplaintCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.category,
    required this.isOwner,
    required this.onReviewed,
    required this.onResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pastelBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.pastelBlueIcon,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                status.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: status == 'resolved'
                      ? AppColors.successGreenDark
                      : AppColors.pastelOrangeIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isOwner && status != 'resolved') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'open')
                  TextButton(
                    onPressed: onReviewed,
                    child: const Text('Mark reviewed'),
                  ),
                TextButton(
                  onPressed: onResolved,
                  child: Text(
                    'Resolve',
                    style: TextStyle(color: AppColors.successGreenDark),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}