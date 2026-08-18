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

class requeststatusView extends StatefulWidget {
  const requeststatusView({super.key});

  @override
  State<requeststatusView> createState() => _requeststatusViewState();
}

class _requeststatusViewState extends State<requeststatusView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final requeststatusController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<requeststatusController>();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refresh();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        final status = controller.status.value;
        final society = controller.society.value;
        final property = controller.property.value;

        return Column(
          children: [
            _Header(status: status),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space20,
                  AppDimens.space24,
                  AppDimens.space20,
                  AppDimens.space32,
                ),
                child: Center(
                  child: AppResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status hero
                        _StatusHero(
                          status: status,
                          societyName: society?.name,
                          pulseController: _pulseController,
                        ),
                        const SizedBox(height: AppDimens.space28),

                        // Request meta
                        _DetailRow(
                          requestId: controller.requestId,
                          submittedAt: controller.submittedAt.value,
                        ),
                        const SizedBox(height: AppDimens.space20),

                        // Timeline
                        _ReviewTimeline(
                          status: status,
                          submittedAt: controller.submittedAt.value,
                        ),
                        const SizedBox(height: AppDimens.space20),

                        // Society
                        if (society != null) ...[
                          Text('SOCIETY', style: AppTextStyles.overline),
                          const SizedBox(height: AppDimens.space10),
                          _SocietySummaryCard(society: society),
                          const SizedBox(height: AppDimens.space20),
                        ],

                        // Property
                        if (property != null) ...[
                          Text('PROPERTY APPLIED FOR', style: AppTextStyles.overline),
                          const SizedBox(height: AppDimens.space10),
                          _PropertySummaryCard(property: property),
                          const SizedBox(height: AppDimens.space20),
                        ],

                        // Notify note (only pending)
                        _NotifyNote(status: status),
                        const SizedBox(height: AppDimens.space28),

                        // Actions
                        AppPrimaryButton(
  label: status == Joinrequeststatus.approved
      ? 'Continue to Dashboard'
      : status == Joinrequeststatus.rejected
          ? 'Request declined'
          : 'Waiting for approval',
  icon: status == Joinrequeststatus.approved
      ? Icons.arrow_forward_rounded
      : Icons.hourglass_top_rounded,
  onPressed: status == Joinrequeststatus.approved
      ? controller.continueToDashboard
      : null, // disabled while pending / rejected
),
                        if (status == Joinrequeststatus.rejected) ...[
                          const SizedBox(height: AppDimens.space12),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // TODO: open contact admin flow
                              },
                              child: Text(
                                'Contact Admin',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header (matches Property Details style)
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Joinrequeststatus status;
  const _Header({required this.status});

  @override
  Widget build(BuildContext context) {
    final (String title, String subtitle) = switch (status) {
      Joinrequeststatus.pending => ('Request Status', 'Awaiting admin review'),
      Joinrequeststatus.approved => ('Request Status', 'You have been approved'),
      Joinrequeststatus.rejected => ('Request Status', 'Request was declined'),
    };

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
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.apartment_rounded,
                      color: AppColors.accentGreen, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textOnDarkMuted),
                  ),
                ],
              ),
            ),
            _HeaderStatusPill(status: status),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatusPill extends StatelessWidget {
  final Joinrequeststatus status;
  const _HeaderStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      Joinrequeststatus.pending => (
          AppColors.pendingBg,
          AppColors.pending,
          'PENDING'
        ),
      Joinrequeststatus.approved => (
          AppColors.pastelGreenBg,
          AppColors.successGreenDark,
          'APPROVED'
        ),
      Joinrequeststatus.rejected => (
          AppColors.dangerBg,
          AppColors.danger,
          'DECLINED'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Hero
// ─────────────────────────────────────────────────────────────────────────────

class _StatusHero extends StatelessWidget {
  final Joinrequeststatus status;
  final String? societyName;
  final AnimationController pulseController;

  const _StatusHero({
    required this.status,
    required this.societyName,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusIcon(status: status, pulseController: pulseController),
        const SizedBox(height: AppDimens.space20),
        Text(
          _titleFor(status),
          style: AppTextStyles.h1.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.space8),
        Text(
          _descriptionFor(status, societyName),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _titleFor(Joinrequeststatus status) {
    switch (status) {
      case Joinrequeststatus.pending:
        return 'Request Submitted!';
      case Joinrequeststatus.approved:
        return 'You\'re In!';
      case Joinrequeststatus.rejected:
        return 'Request Declined';
    }
  }

  String _descriptionFor(Joinrequeststatus status, String? societyName) {
    final name = societyName ?? 'the society';
    switch (status) {
      case Joinrequeststatus.pending:
        return 'Your request to join $name has been sent. You\'ll be notified once the admin reviews it.';
      case Joinrequeststatus.approved:
        return 'Your request to join $name has been approved. Welcome aboard!';
      case Joinrequeststatus.rejected:
        return 'Your request to join $name was not approved. Contact your society admin for details.';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final Joinrequeststatus status;
  final AnimationController pulseController;
  const _StatusIcon({required this.status, required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status) {
      Joinrequeststatus.pending => (
          AppColors.pendingBg,
          AppColors.pending,
          Icons.hourglass_top_rounded
        ),
      Joinrequeststatus.approved => (
          AppColors.pastelGreenBg,
          AppColors.successGreenDark,
          Icons.check_circle_rounded
        ),
      Joinrequeststatus.rejected => (
          AppColors.dangerBg,
          AppColors.danger,
          Icons.cancel_rounded
        ),
    };

    final core = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: fg),
    );

    if (status != Joinrequeststatus.pending) return core;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + (pulseController.value * 0.18);
        final opacity = 1.0 - pulseController.value;
        return SizedBox(
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity * 0.45,
                  child: Container(
                    width: 88,
                    height: 88,
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

// ─────────────────────────────────────────────────────────────────────────────
// Detail Row
// ─────────────────────────────────────────────────────────────────────────────

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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ID',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(requestId, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submitted',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text('$dateStr · $timeStr', style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewTimeline extends StatelessWidget {
  final Joinrequeststatus status;
  final DateTime submittedAt;
  const _ReviewTimeline({required this.status, required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    final isResolved = status != Joinrequeststatus.pending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TIMELINE', style: AppTextStyles.overline),
          const SizedBox(height: AppDimens.space16),
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
            title: status == Joinrequeststatus.rejected ? 'Declined' : 'Decision',
            subtitle: switch (status) {
              Joinrequeststatus.pending => 'Pending',
              Joinrequeststatus.approved => 'Approved — welcome aboard!',
              Joinrequeststatus.rejected => 'Not approved this time',
            },
            isDone: isResolved,
            isActive: false,
            isLast: true,
            doneColor:
                status == Joinrequeststatus.rejected ? AppColors.danger : null,
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
    final markerColor =
        isDone ? (doneColor ?? AppColors.accentGreenDark) : AppColors.border;

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
                            decoration: const BoxDecoration(
                              color: AppColors.pending,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? markerColor.withValues(alpha: 0.4)
                        : AppColors.border,
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
                      color: isDone || isActive
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
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

// ─────────────────────────────────────────────────────────────────────────────
// Society & Property cards
// ─────────────────────────────────────────────────────────────────────────────

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
        border: Border.all(color: AppColors.borderLight),
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
            child: const Icon(Icons.apartment_rounded,
                size: 26, color: AppColors.pastelGreenIcon),
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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (society.isVerified)
            const Icon(Icons.verified_rounded,
                size: 20, color: AppColors.accentGreenDark),
        ],
      ),
    );
  }
}

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
        border: Border.all(color: AppColors.borderLight),
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
                child: const Icon(Icons.home_work_rounded,
                    size: 26, color: AppColors.pastelBlueIcon),
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
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
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
                _SpecChip(
                    icon: Icons.square_foot_rounded,
                    label: '${property.areaSqFt} sq ft'),
              _SpecChip(
                icon: Icons.person_rounded,
                label: property.isOccupied
                    ? 'Occupied · ${property.occupiedBy}'
                    : 'Vacant',
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
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _NotifyNote extends StatelessWidget {
  final Joinrequeststatus status;
  const _NotifyNote({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status != Joinrequeststatus.pending) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_none_rounded,
            size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          'You\'ll be notified via SMS and email',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}