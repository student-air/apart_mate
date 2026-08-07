// lib/presentation/request_status/views/request_status_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/core/widgets/app_responsive_container.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/request_status/controllers/request_status_controller.dart';

class RequestStatusView extends GetView<RequestStatusController> {
  const RequestStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const AppLoading();
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.space24),
              child: AppResponsiveContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusIcon(status: controller.status.value),
                    const SizedBox(height: AppDimens.space24),
                    Text(
                      _titleFor(controller.status.value),
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.space8),
                    Text(
                      _descriptionFor(controller.status.value, controller.society.value?.name),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.space32),
                    if (controller.society.value != null) _SocietySummaryCard(society: controller.society.value!),
                    const SizedBox(height: AppDimens.space32),
                    if (controller.status.value == JoinRequestStatus.approved)
                      AppPrimaryButton(
                        label: 'Continue to Dashboard',
                        onPressed: controller.continueToDashboard,
                      )
                    else
                      AppSecondaryButton(
                        label: 'Refresh Status',
                        leading: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.primaryDark),
                        onPressed: controller.refresh,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _titleFor(JoinRequestStatus status) {
    switch (status) {
      case JoinRequestStatus.pending:
        return 'Request Submitted!';
      case JoinRequestStatus.approved:
        return 'You\'re In!';
      case JoinRequestStatus.rejected:
        return 'Request Declined';
    }
  }

  String _descriptionFor(JoinRequestStatus status, String? societyName) {
    final name = societyName ?? 'the society';
    switch (status) {
      case JoinRequestStatus.pending:
        return 'Your request to join $name has been sent. You\'ll be notified once the admin reviews it.';
      case JoinRequestStatus.approved:
        return 'Your request to join $name has been approved. Welcome aboard!';
      case JoinRequestStatus.rejected:
        return 'Your request to join $name was not approved. Contact your society admin for details.';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final JoinRequestStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status) {
      JoinRequestStatus.pending => (AppColors.pendingBg, AppColors.pending, Icons.hourglass_top_rounded),
      JoinRequestStatus.approved => (AppColors.pastelGreenBg, AppColors.successGreenDark, Icons.check_circle_rounded),
      JoinRequestStatus.rejected => (AppColors.dangerBg, AppColors.danger, Icons.cancel_rounded),
    };

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: fg),
    );
  }
}

class _SocietySummaryCard extends StatelessWidget {
  final dynamic society; // SocietyModel
  const _SocietySummaryCard({required this.society});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.apartment_rounded, size: 24, color: AppColors.pastelGreenIcon),
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
        ],
      ),
    );
  }
}