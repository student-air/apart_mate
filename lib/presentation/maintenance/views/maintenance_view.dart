// lib/presentation/maintenance/views/maintenance_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/presentation/maintenance/controllers/maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
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
                        Obx(
                          () => Text(
                            controller.isTenant
                                ? 'Your monthly maintenance'
                                : 'Maintenance payments',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textOnDarkMuted,
                            ),
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
                        Icons.payments_rounded,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return controller.isTenant
                  ? _TenantBody(controller: controller)
                  : _OwnerBody(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TENANT
// ─────────────────────────────────────────────────────────────
class _TenantBody extends StatelessWidget {
  final MaintenanceController controller;
  const _TenantBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPaid = controller.isCurrentMonthPaid;
      final amount = controller.monthlyAmount.value;
      final label = controller.propertyLabel.value;

      return RefreshIndicator(
        onRefresh: controller.load,
        color: AppColors.accentGreenDark,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isPaid ? AppColors.accentGreen : AppColors.danger,
                borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                boxShadow: [
                  BoxShadow(
                    color: (isPaid ? AppColors.accentGreen : AppColors.danger)
                        .withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.textOnDark.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPaid
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: AppColors.textOnDark,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textOnDark.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPaid ? 'PAID' : 'PENDING',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isPaid ? 'This month paid' : 'Amount due this month',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. $amount',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label.isEmpty ? 'Your flat' : label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Payment history',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (controller.history.isEmpty)
              const _EmptyCard(text: 'No payment history yet')
            else
              ...controller.history.map((h) {
                final paid = h.status == 'paid';
                return _HistoryTile(
                  title: '${controller.monthName(h.month)} ${h.year}',
                  amount: 'Rs. ${h.amount}',
                  isPaid: paid,
                  subtitle: paid && h.paidAt != null
                      ? 'Paid on ${_fmt(h.paidAt!)}'
                      : 'Payment pending',
                );
              }),
          ],
        ),
      );
    });
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ─────────────────────────────────────────────────────────────
// OWNER
// ─────────────────────────────────────────────────────────────
class _OwnerBody extends StatelessWidget {
  final MaintenanceController controller;
  const _OwnerBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pendingCount =
          controller.ownerRows.where((e) => e.status != 'paid').length;
      final paidCount =
          controller.ownerRows.where((e) => e.status == 'paid').length;

      return RefreshIndicator(
        onRefresh: controller.load,
        color: AppColors.accentGreenDark,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly maintenance',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${controller.monthlyAmount.value}',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (controller.propertyLabel.value.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      controller.propertyLabel.value,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDark.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'Pending',
                    count: pendingCount,
                    bg: AppColors.dangerBg,
                    fg: AppColors.danger,
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    label: 'Paid',
                    count: paidCount,
                    bg: AppColors.successGreenBg,
                    fg: AppColors.successGreenDark,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Records',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (controller.ownerRows.isEmpty)
              const _EmptyCard(text: 'No payment records yet')
            else
              ...controller.ownerRows.map((h) {
                final isPaid = h.status == 'paid';
                final monthLabel =
                    '${controller.monthName(h.month)} ${h.year}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? AppColors.successGreenBg
                          : AppColors.dangerBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
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
                              color: isPaid
                                  ? AppColors.successGreenBg
                                  : AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(h),
                              style: AppTextStyles.h4.copyWith(
                                color: isPaid
                                    ? AppColors.successGreenDark
                                    : AppColors.danger,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tenantDisplayName(h),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  monthLabel,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(isPaid: isPaid),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoBlock(
                              label: 'Amount',
                              value: 'Rs. ${h.amount}',
                              valueColor: isPaid
                                  ? AppColors.successGreenDark
                                  : AppColors.danger,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppColors.borderLight,
                          ),
                          Expanded(
                            child: _InfoBlock(
                              label: 'Property',
                              value: _propertyLabel(h),
                            ),
                          ),
                        ],
                      ),
                      if (!isPaid) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.markPaid(h.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreenDark,
                              foregroundColor: AppColors.textOnDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(
                              'Mark as paid',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ] else if (h.paidAt != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              size: 16,
                              color: AppColors.successGreenDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Paid on ${h.paidAt!.day}/${h.paidAt!.month}/${h.paidAt!.year}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.successGreenDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  String _initials(MaintenancePaymentModel h) {
    final name = h.tenantName.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    if (h.tenantUserId.isNotEmpty) {
      return h.tenantUserId.length >= 2
          ? h.tenantUserId.substring(0, 2).toUpperCase()
          : h.tenantUserId[0].toUpperCase();
    }
    return '?';
  }

  String _tenantDisplayName(MaintenancePaymentModel h) {
    if (h.tenantName.trim().isNotEmpty) return h.tenantName.trim();
    return 'Tenant';
  }

  String _propertyLabel(MaintenancePaymentModel h) {
    if (h.propertyLabel.trim().isNotEmpty) return h.propertyLabel.trim();
    return h.propertyId.isEmpty ? '—' : 'Unit';
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: AppTextStyles.h4.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: fg),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoBlock({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final bool isPaid;

  const _HistoryTile({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPaid ? AppColors.successGreenBg : AppColors.dangerBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isPaid ? AppColors.successGreenBg : AppColors.dangerBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: isPaid ? AppColors.successGreenDark : AppColors.danger,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(isPaid: isPaid),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isPaid;
  const _StatusChip({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.successGreenBg : AppColors.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'PAID' : 'PENDING',
        style: AppTextStyles.labelSmall.copyWith(
          color: isPaid ? AppColors.successGreenDark : AppColors.danger,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}