import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/presentation/members/controllers/members_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/data/repositories/local_tenant_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';

class AddTenantController extends GetxController {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();

  final isLoading = false.obs;
  final selectedPropertyId = RxnString();

  late final DashboardController _dashboard;
  late final LocalTenantRepository _tenantRepo;

  List<PropertyModel> get vacantProperties {
    final all = _dashboard.propertiesInCurrentSociety;
    return all.where((p) => !p.isOccupied).toList();
  }

  @override
void onInit() {
  super.onInit();
  _dashboard = Get.find<DashboardController>();
  _tenantRepo = Get.find<ITenantRepository>() as LocalTenantRepository;
}

  void selectProperty(String id) {
    selectedPropertyId.value = id;
  }

  Future<void> saveTenant() async {
    final name = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final cnic = cnicCtrl.text.trim();
    final propId = selectedPropertyId.value;

    if (name.isEmpty || phone.isEmpty || cnic.isEmpty) {
      AppSnackbar.info('Missing fields', 'Please fill all fields');
      return;
    }
    if (propId == null) {
      AppSnackbar.info('Select property', 'Please select a vacant property');
      return;
    }

    final property = vacantProperties.firstWhere((p) => p.id == propId);
    final label = 'Flat ${property.flatNumber} · ${property.building}';

    isLoading.value = true;
    try {
      final tenant = await _tenantRepo.createTenant(
        fullName: name,
        phone: phone,
        cnic: cnic,
        propertyId: propId,
        propertyLabel: label,
      );

      // Show confirmation sheet with code
      await _showInviteCodeSheet(tenant);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showInviteCodeSheet(TenantModel tenant) async {
  await Get.bottomSheet(
    Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Success icon
          Container(
  width: 64,
  height: 64,
  decoration: const BoxDecoration(
    color: Color(0xFF22C55E), // solid green
    shape: BoxShape.circle,
  ),
  alignment: Alignment.center,
  child: const Icon(
    Icons.check_rounded,
    size: 34,
    color: Colors.white, // white tick
  ),
),
          const SizedBox(height: 18),

          // Title
          Text(
            AppStrings.tenantAdded,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            AppStrings.shareCodeWith(tenant.fullName),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          
          // Code card (only the code)
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
  decoration: BoxDecoration(
    color: AppColors.successGreenDark.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    border: Border.all(color: AppColors.borderLight),
  ),
  child: Text(
    tenant.inviteCode,
    textAlign: TextAlign.center,
    style: AppTextStyles.h2.copyWith(
      letterSpacing: 6,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  ),
),
const SizedBox(height: 12),

// Outside the box
Text(
  AppStrings.tenantWillUseCode,
  style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.textMuted,
  ),
  textAlign: TextAlign.center,
),
const SizedBox(height: 28),

// Done button
AppPrimaryButton(
  label: AppStrings.done,
  onPressed: () {
    Get.back(); // close sheet

    // If MembersController is already open, refresh it
    if (Get.isRegistered<MembersController>()) {
      Get.find<MembersController>().loadMembers();
    }

    // Go to Members (replace add-tenant so back doesn't return to form)
    Get.offNamed(AppRoutes.members);
  },
),
        ],
      ),
    ),
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
  );
}

  @override
  void onClose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    super.onClose();
  }
}