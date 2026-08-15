// lib/core/widgets/send_complaint_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
// import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';

class SendComplaintSheet extends StatefulWidget {
  const SendComplaintSheet({super.key});

  static Future<void> open() {
    return Get.bottomSheet(
      const SendComplaintSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<SendComplaintSheet> createState() => _SendComplaintSheetState();
}

class _SendComplaintSheetState extends State<SendComplaintSheet> {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final categories = const [
    'Plumbing',
    'Electrical',
    'Cleanliness',
    'Security',
    'Noise',
    'General',
  ];

  String selectedCategory = 'General';
  bool isLoading = false;

  bool get _isTenant => AppNavigation.isTenant;

  Future<void> _submit() async {
    final auth = Get.find<IAuthRepository>();
    final user = auth.currentUser;
    if (user == null) return;

    final title = titleCtrl.text.trim();
    final desc = descriptionCtrl.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      AppSnackbar.info('Missing fields', 'Enter title and description');
      return;
    }

    String? societyId;
    if (Get.isRegistered<DashboardController>()) {
      societyId = Get.find<DashboardController>().society.value?.id;
    }
    if (societyId == null || societyId.isEmpty) {
      societyId =
          await Get.find<ISocietyRepository>().getSocietyIdForUser(user.id);
    }
    if (societyId == null || societyId.isEmpty) {
      AppSnackbar.info(
        'No society',
        'Select a society on the dashboard first',
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final complaint = ComplaintModel(
        id: 'complaint_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: '',
        societyId: societyId,
        raisedByUserId: user.id,
        raisedByRole: _isTenant ? 'tenant' : 'owner',
        raisedByName: user.fullName,
        title: title,
        description: desc,
        category: selectedCategory,
        status: 'open',
        assignedTo: 'society_admin',
        propertyLabel: 'Society complaint',
        createdAt: DateTime.now(),
      );

      await Get.find<IComplaintRepository>().saveComplaint(complaint);

      Get.back();
      AppSnackbar.success(
        'Submitted',
        'Complaint sent to society admin',
      );
    } catch (_) {
      AppSnackbar.error('Failed', 'Could not submit complaint');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.92;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
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
                        alignment: Alignment.center,
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
                              _isTenant
                                  ? 'Sent for your active society (owner or admin)'
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
                padding: EdgeInsets.fromLTRB(20, 18, 20, 12 + bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      style: AppTextStyles.bodyMedium,
                      decoration:
                          _decoration('e.g. Water leakage in kitchen'),
                    ),
                    const SizedBox(height: 14),
                    Text('Description', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionCtrl,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium,
                      decoration:
                          _decoration('Describe the issue clearly…'),
                    ),
                    const SizedBox(height: 16),
                    Text('Category', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((c) {
                        final selected = selectedCategory == c;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedCategory = c),
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
                    ),
                    const SizedBox(height: 14),
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
                              _isTenant
                                  ? 'This will be filed under your active society and routed automatically.'
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
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
                        child: isLoading
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: isLoading ? null : () => Get.back(),
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
            ),
          ],
        ),
      ),
    );
  }
}