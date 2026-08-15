import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

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
    'Noise',
    'Cleaning',
    'Security',
    'Other',
  ];

  String? selectedCategory;
  String? selectedPropertyId;
  List<PropertyModel> properties = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final auth = Get.find<IAuthRepository>();
    final user = auth.currentUser;
    if (user == null) return;
    final repo = Get.find<IPropertyRepository>();
    final list = await repo.getPropertiesForUser(user.id);
    setState(() {
      properties = list;
      if (list.length == 1) selectedPropertyId = list.first.id;
    });
  }

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
    if (selectedCategory == null) {
      AppSnackbar.info('Category', 'Select a category');
      return;
    }
    if (selectedPropertyId == null) {
      AppSnackbar.info('Property', 'Select a property');
      return;
    }

    final property = properties.firstWhere((p) => p.id == selectedPropertyId);
    final isTenant = AppNavigation.isTenant;

    // Routing:
    // - Tenant → owner if property_owner, else society_admin
    // - Owner filing → always society_admin (My Complaints)
    final assignedTo = isTenant
        ? (property.maintenanceBy == 'society_admin'
            ? 'society_admin'
            : 'owner')
        : 'society_admin';

    setState(() => isLoading = true);
    try {
      final complaint = ComplaintModel(
        id: 'complaint_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: property.id,
        societyId: property.societyId,
        raisedByUserId: user.id,
        raisedByRole: isTenant ? 'tenant' : 'owner',
        raisedByName: user.fullName,
        title: title,
        description: desc,
        category: selectedCategory!,
        status: 'open',
        assignedTo: assignedTo,
        propertyLabel: 'Flat ${property.flatNumber} · ${property.building}',
        createdAt: DateTime.now(),
      );

      await Get.find<IComplaintRepository>().saveComplaint(complaint);

      Get.back();
      AppSnackbar.success(
        'Submitted',
        assignedTo == 'society_admin'
            ? 'Complaint sent to society admin'
            : 'Complaint sent to property owner',
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Send Complaint', style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text(
              'Describe the issue and submit',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Title',
              hint: 'e.g. Water leakage',
              controller: titleCtrl,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Description',
              hint: 'What happened?',
              controller: descriptionCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Category', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final selected = selectedCategory == c;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.pastelGreenBg
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.accentGreen
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      c,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.successGreenDark
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Property', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            if (properties.isEmpty)
              Text(
                'No property found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              )
            else
              ...properties.map((p) {
                final selected = selectedPropertyId == p.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPropertyId = p.id),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.pastelGreenBg
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentGreen
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        'Flat ${p.flatNumber} · ${p.building}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: 'Submit Complaint',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}