import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_loading.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/presentation/complaint/controllers/complaint_controller.dart';

class ComplaintView extends GetView<ComplaintListController> {
  const ComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: () => _openFileComplaintSheet(context),
        child: const Icon(Icons.add, color: AppColors.accentGreen),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                    child: Text(
                      'Complaints',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs — owner only (All = inbox, My = sent to admin)
          if (!controller.isTenant)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: _TabChip(
                        label: 'All Complaints',
                        count: controller.inbox.length,
                        selected: controller.selectedTab.value == 0,
                        onTap: () => controller.switchTab(0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TabChip(
                        label: 'My Complaints',
                        count: controller.mine.length,
                        selected: controller.selectedTab.value == 1,
                        onTap: () => controller.switchTab(1),
                      ),
                    ),
                  ],
                );
              }),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Complaints',
                  style: AppTextStyles.h4,
                ),
              ),
            ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoading();
              }

              final list = controller.visible;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.isTenant
                              ? 'No complaints yet'
                              : controller.selectedTab.value == 0
                                  ? 'No complaints received'
                                  : 'You haven’t sent any complaints',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.load,
                color: AppColors.accentGreenDark,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
  final c = list[i];
  return Dismissible(
    key: ValueKey(c.id),
    direction: DismissDirection.endToStart, // swipe left
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
    ),
    confirmDismiss: (_) async {
      return await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Delete complaint?'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    },
    onDismissed: (_) => controller.deleteComplaint(c.id),
    child: _ComplaintCard(
      complaint: c,
      isInbox: !controller.isTenant && controller.selectedTab.value == 0,
      onStatus: controller.isTenant
          ? null
          : (status) => controller.updateStatus(c.id, status),
    ),
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

  void _openFileComplaintSheet(BuildContext context) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final category = 'General'.obs;
  final categories = const [
    'Plumbing',
    'Electrical',
    'Cleanliness',
    'Security',
    'Noise',
    'General',
  ];
  final isSubmitting = false.obs;

  Get.bottomSheet(
    SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark header band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.report_problem_rounded,
                          color: AppColors.accentGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File a complaint',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textOnDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.isTenant
                                  ? 'Routed to owner or society admin automatically'
                                  : 'Sent to the society admin for your active society',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textOnDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'e.g. Water leakage in kitchen',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.accentGreen,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Description', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue clearly…',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.accentGreen,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Category', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 10),
                    Obx(() {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((c) {
                          final selected = category.value == c;
                          return GestureDetector(
                            onTap: () => category.value = c,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.pastelGreenBg
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.accentGreen
                                          .withValues(alpha: 0.55)
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                c,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: selected
                                      ? AppColors.accentGreenDark
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 14),
                    // Routing note — no property UI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlueBg.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.pastelBlueIcon,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.isTenant
                                  ? 'This will be filed under your active society and routed automatically (owner or society admin).'
                                  : 'This will be filed under your selected society and sent to the society admin.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.pastelBlueIcon,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting.value
                            ? null
                            : () async {
                                final title = titleCtrl.text.trim();
                                final desc = descCtrl.text.trim();
                                if (title.isEmpty || desc.isEmpty) {
                                  Get.snackbar(
                                    'Missing info',
                                    'Please add a title and description',
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                  return;
                                }
                                isSubmitting.value = true;
                                try {
                                  // TODO: call controller method that uses active society only
                                  // await controller.submitComplaint(
                                  //   title: title,
                                  //   description: desc,
                                  //   category: category.value,
                                  // );
                                  Get.back();
                                  Get.snackbar(
                                    'Submitted',
                                    'Complaint filed for your active society',
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                  await controller.load();
                                } finally {
                                  isSubmitting.value = false;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.accentGreen,
                          disabledBackgroundColor:
                              AppColors.primaryDark.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.accentGreen,
                                ),
                              )
                            : Text(
                                'Submit complaint',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.pastelGreenBg : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.accentGreen.withValues(alpha: 0.5)
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected
                    ? AppColors.accentGreenDark
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final bool isInbox;
  final void Function(String status)? onStatus;

  const _ComplaintCard({
    required this.complaint,
    required this.isInbox,
    this.onStatus,
  });

  Color get _statusBg {
    switch (complaint.status) {
      case 'resolved':
        return AppColors.pastelGreenBg;
      case 'reviewed':
        return AppColors.pastelBlueBg;
      default:
        return AppColors.pastelOrangeBg;
    }
  }

  Color get _statusFg {
    switch (complaint.status) {
      case 'resolved':
        return AppColors.accentGreenDark;
      case 'reviewed':
        return AppColors.pastelBlueIcon;
      default:
        return AppColors.pastelOrangeIcon;
    }
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  complaint.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  complaint.status.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _statusFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
Text(
  complaint.description,
  // no maxLines / overflow — full content
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.textSecondary,
    height: 1.4,
  ),
),
          const SizedBox(height: 10),

          // Flat · Floor · Building  e.g. B-501 · 5th Floor · Building B
          if (complaint.propertyLabel.isNotEmpty) ...[
  const SizedBox(height: 10),
  Row(
    children: [
      Icon(Icons.home_work_outlined,
          size: 16, color: AppColors.accentGreenDark),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          complaint.propertyLabel, // flat · floor · building
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
],
          
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.category_outlined,
                label: complaint.category,
              ),
              if (isInbox)
                _MetaChip(
                  icon: Icons.person_outline,
                  label: complaint.raisedByName,
                ),
              _MetaChip(
                icon: Icons.schedule,
                label: DateFormat('d MMM').format(complaint.createdAt),
              ),
            ],
          ),
          if (isInbox && onStatus != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (complaint.status != 'reviewed')
                  TextButton(
                    onPressed: () => onStatus!('reviewed'),
                    child: Text(
                      'Mark reviewed',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.pastelBlueIcon,
                      ),
                    ),
                  ),
                if (complaint.status != 'resolved')
                  TextButton(
                    onPressed: () => onStatus!('resolved'),
                    child: Text(
                      'Resolve',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.accentGreenDark,
                      ),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}