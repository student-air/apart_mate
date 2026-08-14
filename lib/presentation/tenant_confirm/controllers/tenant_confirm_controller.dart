// lib/presentation/tenant_confirm/controllers/tenant_confirm_controller.dart

import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class TenantConfirmController extends GetxController {
  late final TenantModel tenant;
  late final PropertyModel property;
  final isLoading = false.obs;
  final agreedToDetails = false.obs;

  late final ITenantRepository _tenantRepo;

  @override
  void onInit() {
    super.onInit();
    _tenantRepo = Get.find<ITenantRepository>();
    final args = Get.arguments as Map?;
    if (args == null ||
        args['tenant'] is! TenantModel ||
        args['property'] is! PropertyModel) {
      Get.back();
      return;
    }
    tenant = args['tenant'] as TenantModel;
    property = args['property'] as PropertyModel;
  }

  /// Who should the tenant contact?
  /// Later: look up manager assigned to this property.
  String get contactRole => 'Owner';

  String get contactName =>
      contactRole == 'Manager' ? 'Property Manager' : 'Property Owner';

  void toggleAgreement(bool? value) {
    agreedToDetails.value = value ?? false;
  }

  Future<void> continueToDashboard() async {
  if (!agreedToDetails.value) {
    AppSnackbar.info(
      'Confirm details',
      'Please confirm that the details are correct',
    );
    return;
  }

  isLoading.value = true;
  try {
    final updatedTenant = TenantModel(
      id: tenant.id,
      fullName: tenant.fullName,
      phone: tenant.phone,
      cnic: tenant.cnic,
      propertyId: tenant.propertyId,
      propertyLabel: tenant.propertyLabel,
      inviteCode: tenant.inviteCode,
      status: 'joined',
      createdAt: tenant.createdAt,
    );

    await _tenantRepo.saveTenant(updatedTenant);

    final userId = Get.find<IAuthRepository>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      await _tenantRepo.linkTenantToUser(
        userId: userId,
        tenant: updatedTenant,
      );
    }

    // REQUIRED: mark tenant role + set active role to tenant
    Get.find<AppSession>().registerTenant();

    AppSnackbar.success('Welcome', 'You’re all set as a tenant');

    Get.offAllNamed(
  AppRoutes.tenantDashboard,
  arguments: {
    'tenant': updatedTenant,
    'property': property,
  },
);
  } finally {
    isLoading.value = false;
  }
}

  void reportWrongDetails() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
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
                    const SizedBox(height: 18),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.report_problem_rounded,
                        color: AppColors.accentGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Report incorrect details',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We’ll connect you with the right person to fix this',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact',
                            style: AppTextStyles.overline,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contactName,
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            contactRole,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          AppSnackbar.info(
                            'Coming soon',
                            'Contact flow will be available soon',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.accentGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Contact $contactRole',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Cancel',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusFull),
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

  void goBack() => Get.back();
}