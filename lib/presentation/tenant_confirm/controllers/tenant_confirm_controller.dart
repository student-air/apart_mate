// lib/presentation/tenant_confirm/controllers/tenant_confirm_controller.dart

import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class TenantConfirmController extends GetxController {
  late final TenantModel tenant;
  late final PropertyModel property;
  final isLoading = false.obs;

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
  /// For now defaults to Owner.
  String get contactRole {
    // TODO: wire IManagerRepository
    // final manager = _managerRepo.getForProperty(property.id);
    // return manager != null ? 'Manager' : 'Owner';
    return 'Owner';
  }

  String get contactName {
    // TODO: real names from profile / manager model
    return contactRole == 'Manager' ? 'Property Manager' : 'Property Owner';
  }

//   Future<void> continueToDashboard() async {
//   isLoading.value = true;
//   try {
//     await _tenantRepo.saveTenant(
//       TenantModel(
//         id: tenant.id,
//         fullName: tenant.fullName,
//         phone: tenant.phone,
//         cnic: tenant.cnic,
//         propertyId: tenant.propertyId,
//         propertyLabel: tenant.propertyLabel,
//         inviteCode: tenant.inviteCode,
//         status: 'joined',
//         createdAt: tenant.createdAt,
//       ),
//     );

//     AppSnackbar.info(
//       'Almost there',
//       'Tenant dashboard will be available soon',
//     );
//     // Do NOT navigate to owner dashboard
//     // Get.offAllNamed(AppRoutes.dashboard);
//   } finally {
//     isLoading.value = false;
//   }
// }

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
            // Dark top band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
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
                  // Who you’ll contact
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusXl),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: contactRole == 'Manager'
                                ? AppColors.pastelBlueBg
                                : AppColors.pastelGreenBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            contactRole == 'Manager'
                                ? Icons.badge_rounded
                                : Icons.person_rounded,
                            color: contactRole == 'Manager'
                                ? AppColors.pastelBlueIcon
                                : AppColors.pastelGreenIcon,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contactName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Can update your tenant & property info',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: contactRole == 'Manager'
                                ? AppColors.pastelBlueBg
                                : AppColors.pastelGreenBg,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusFull,
                            ),
                          ),
                          child: Text(
                            contactRole,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: contactRole == 'Manager'
                                  ? AppColors.pastelBlueIcon
                                  : AppColors.accentGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                  const SizedBox(height: 16),

                  // Warning tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pastelOrangeBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.pastelOrangeIcon,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Don’t continue until the $contactRole corrects your details.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.pastelOrangeIcon,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        AppSnackbar.info(
                          'Contact $contactRole',
                          'Messaging $contactName — coming soon',
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

                  // Cancel
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
      backgroundColor: AppColors.danger, // or Color(0xFFEF4444)
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull), // full pill
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

final agreedToDetails = false.obs;

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
  void goBack() => Get.back();
}