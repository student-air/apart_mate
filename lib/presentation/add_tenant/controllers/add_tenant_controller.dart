// lib/presentation/add_tenant/controllers/add_tenant_controller.dart

import 'package:apart_mate/data/repositories/firebase_tenant_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
// import 'package:apart_mate/data/repositories/local_tenant_repository.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/presentation/members/controllers/members_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class AddTenantController extends GetxController {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();

  final isLoading = false.obs;
  final selectedPropertyId = RxnString();

  late final DashboardController _dashboard;
  late final IPropertyRepository _propertyRepo;
  late final IAuthRepository _auth;

  List<PropertyModel> get vacantProperties {
    final all = _dashboard.propertiesInCurrentSociety;
    return all.where((p) => !p.isOccupied).toList();
  }


late final FirebaseTenantRepository _tenantRepo;

@override
void onInit() {
  super.onInit();
  _dashboard = Get.find<DashboardController>();
  _tenantRepo = Get.find<ITenantRepository>() as FirebaseTenantRepository;
  _propertyRepo = Get.find<IPropertyRepository>();
  _auth = Get.find<IAuthRepository>();
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

  final owner = _auth.currentUser;
  if (owner == null) {
    AppSnackbar.error('Not signed in', 'Please sign in again');
    return;
  }

  final property = vacantProperties.firstWhere((p) => p.id == propId);
  final label = 'Flat ${property.flatNumber} · ${property.building}';

  isLoading.value = true;
  try {
    // 1) Create tenant invite in Firestore (+ owner contact + ownerUserId)
    final tenant = await _tenantRepo.createTenant(
      fullName: name,
      phone: phone,
      cnic: cnic,
      propertyId: propId,
      propertyLabel: label,
      ownerName: owner.fullName,
      ownerPhone: owner.phone,
      ownerEmail: owner.email,
      ownerUserId: owner.id,
    );

    // 2) Mark property occupied
    await _propertyRepo.saveProperty(
      property.copyWith(
        isOccupied: true,
        occupiedBy: 'tenant',
      ),
    );

    // 3) Refresh dashboard
    if (Get.isRegistered<DashboardController>()) {
      await _dashboard.refresh();
    }

    // 4) Invite code sheet
    await _showInviteCodeSheet(tenant);
  } catch (e) {
    AppSnackbar.error('Failed', 'Could not add tenant. Please try again.');
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                size: 34,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.tenantAdded,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.shareCodeWith(tenant.fullName),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.successGreenDark.withValues(alpha: 0.1),
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
            Text(
              AppStrings.tenantWillUseCode,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AppPrimaryButton(
              label: AppStrings.done,
              onPressed: () {
                Get.back();
                if (Get.isRegistered<MembersController>()) {
                  Get.find<MembersController>().loadMembers();
                }
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