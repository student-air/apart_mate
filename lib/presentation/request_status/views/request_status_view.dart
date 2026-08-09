// lib/presentation/request_status/views/request_status_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/core/widgets/app_responsive_container.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/request_status/controllers/request_status_controller.dart';

class RequestStatusView extends StatefulWidget {
  const RequestStatusView({super.key});

  @override
  State<RequestStatusView> createState() => _RequestStatusViewState();
}

class _RequestStatusViewState extends State<RequestStatusView> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestStatusController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const AppLoading();
          }

          final status = controller.status.value;
          final society = controller.society.value;
          final property = controller.property.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.space24),
            child: Center(
              child: AppResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          _StatusIcon(status: status, pulseController: _pulseController),
                          const SizedBox(height: AppDimens.space28),
                          Text(
                            _titleFor(status),
                            style: AppTextStyles.h1.copyWith(fontSize: 26),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.space10),
                          Text(
                            _descriptionFor(status, society?.name),
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.space12),
                          _StatusBadge(status: status),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.space32),
                    _DetailRow(requestId: controller.requestId, submittedAt: controller.submittedAt.value),
                    const SizedBox(height: AppDimens.space20),
                    _ReviewTimeline(status: status, submittedAt: controller.submittedAt.value),
                    const SizedBox(height: AppDimens.space20),
                    if (society != null) ...[
                      Text('SOCIETY', style: AppTextStyles.overline),
                      const SizedBox(height: AppDimens.space10),
                      _SocietySummaryCard(society: society),
                      const SizedBox(height: AppDimens.space20),
                    ],
                    if (property != null) ...[
                      Text('PROPERTY APPLIED FOR', style: AppTextStyles.overline),
                      const SizedBox(height: AppDimens.space10),
                      _PropertySummaryCard(property: property),
                      const SizedBox(height: AppDimens.space20),
                    ],
                    _NotifyNote(status: status),
                    const SizedBox(height: AppDimens.space24),
                    if (status == JoinRequestStatus.approved)
                      AppPrimaryButton(
                        label: 'Continue to Dashboard',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: controller.continueToDashboard,
                      )
                    else ...[
  AppPrimaryButton(
    label: 'Continue',
    icon: Icons.arrow_forward_rounded,
    onPressed: controller.continueToDashboard,
  ),
  if (status == JoinRequestStatus.rejected) ...[
    const SizedBox(height: AppDimens.space12),
    Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Contact Admin',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ),
  ],
],
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
  final AnimationController pulseController;
  const _StatusIcon({required this.status, required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status) {
      JoinRequestStatus.pending => (AppColors.pendingBg, AppColors.pending, Icons.hourglass_top_rounded),
      JoinRequestStatus.approved => (AppColors.pastelGreenBg, AppColors.successGreenDark, Icons.check_circle_rounded),
      JoinRequestStatus.rejected => (AppColors.dangerBg, AppColors.danger, Icons.cancel_rounded),
    };

    final core = Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 44, color: fg),
    );

    if (status != JoinRequestStatus.pending) return core;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + (pulseController.value * 0.18);
        final opacity = 1.0 - pulseController.value;
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity * 0.5,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  ),
                ),
              ),
              core,
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final JoinRequestStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      JoinRequestStatus.pending => (AppColors.pendingBg, AppColors.pending, 'PENDING REVIEW'),
      JoinRequestStatus.approved => (AppColors.pastelGreenBg, AppColors.successGreenDark, 'APPROVED'),
      JoinRequestStatus.rejected => (AppColors.dangerBg, AppColors.danger, 'DECLINED'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: fg, letterSpacing: 0.6)),
    );
  }
}

/// Request ID + submission date/time, side by side.
class _DetailRow extends StatelessWidget {
  final String requestId;
  final DateTime submittedAt;
  const _DetailRow({required this.requestId, required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(submittedAt);
    final timeStr = DateFormat('hh:mm a').format(submittedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request ID', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 3),
                Text(requestId, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submitted', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 3),
                Text('$dateStr · $timeStr', style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual 3-step timeline: Submitted -> Under Review -> Decision.
class _ReviewTimeline extends StatelessWidget {
  final JoinRequestStatus status;
  final DateTime submittedAt;
  const _ReviewTimeline({required this.status, required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    // step 0 = submitted (always done), step 1 = under review
    // (done once resolved either way, active while pending),
    // step 2 = decision (done only once resolved).
    final isResolved = status != JoinRequestStatus.pending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _TimelineStep(
            title: 'Request Submitted',
            subtitle: DateFormat('dd MMM, hh:mm a').format(submittedAt),
            isDone: true,
            isActive: false,
            isLast: false,
          ),
          _TimelineStep(
            title: 'Under Review',
            subtitle: isResolved ? 'Reviewed by admin' : 'Waiting for admin action',
            isDone: isResolved,
            isActive: !isResolved,
            isLast: false,
          ),
          _TimelineStep(
            title: status == JoinRequestStatus.rejected ? 'Declined' : 'Decision',
            subtitle: switch (status) {
              JoinRequestStatus.pending => 'Pending',
              JoinRequestStatus.approved => 'Approved — welcome aboard!',
              JoinRequestStatus.rejected => 'Not approved this time',
            },
            isDone: isResolved,
            isActive: false,
            isLast: true,
            doneColor: status == JoinRequestStatus.rejected ? AppColors.danger : null,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final Color? doneColor;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    this.doneColor,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = isDone ? (doneColor ?? AppColors.accentGreenDark) : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? markerColor : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: markerColor, width: 2),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : isActive
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.pending, shape: BoxShape.circle),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? markerColor.withValues(alpha: 0.4) : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimens.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDone || isActive ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocietySummaryCard extends StatelessWidget {
  final SocietyModel society;
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.apartment_rounded, size: 26, color: AppColors.pastelGreenIcon),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(society.name, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  '${society.address}, ${society.city}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (society.isVerified)
            const Icon(Icons.verified_rounded, size: 20, color: AppColors.accentGreenDark),
        ],
      ),
    );
  }
}

/// The flat/property details submitted alongside this join request.
class _PropertySummaryCard extends StatelessWidget {
  final PropertyModel property;
  const _PropertySummaryCard({required this.property});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.pastelBlueBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.home_work_rounded, size: 26, color: AppColors.pastelBlueIcon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flat ${property.flatNumber}', style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      '${property.building} · ${property.floor}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: AppDimens.space20,
            runSpacing: AppDimens.space12,
            children: [
              _SpecChip(icon: Icons.apartment_rounded, label: property.propertyType),
              _SpecChip(icon: Icons.bed_rounded, label: property.flatType),
              if (property.areaSqFt.isNotEmpty)
                _SpecChip(icon: Icons.square_foot_rounded, label: '${property.areaSqFt} sq ft'),
              _SpecChip(
                icon: Icons.person_rounded,
                label: property.isOccupied ? 'Occupied · ${property.occupiedBy}' : 'Vacant',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _NotifyNote extends StatelessWidget {
  final JoinRequestStatus status;
  const _NotifyNote({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status != JoinRequestStatus.pending) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_none_rounded, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          'You\'ll be notified via SMS and email',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}