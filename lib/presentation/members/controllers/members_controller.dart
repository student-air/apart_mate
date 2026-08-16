import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class MembersController extends GetxController {
  final isLoading = false.obs;
  final tenants = <TenantModel>[].obs;
  final selectedTab = 0.obs; // 0 = Tenants, 1 = Managers

  late final IPropertyRepository _propertyRepo;
  late final ITenantRepository _tenantRepo;

  @override
void onInit() {
  super.onInit();
  _tenantRepo = Get.find<ITenantRepository>();
  _propertyRepo = Get.find<IPropertyRepository>();
  loadMembers();
}

void copyCode(String code) {
  Clipboard.setData(ClipboardData(text: code));
  AppSnackbar.success('Copied', 'Invite code copied');
}

Future<void> deleteTenant(TenantModel tenant) async {
  final confirmed = await Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trash icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Remove tenant?',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'This will permanently remove "${tenant.fullName}" from the list and set the property to vacant.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Red Delete button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: AppColors.danger.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(
                  'Delete',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );

  if (confirmed != true) return;

  try {
    await _tenantRepo.deleteTenant(tenant.id);

    if (tenant.propertyId.isNotEmpty) {
      final property = await _propertyRepo.getPropertyById(tenant.propertyId);
      if (property != null) {
        await _propertyRepo.saveProperty(
          property.copyWith(isOccupied: false, occupiedBy: ''),
        );
      }
    }

    tenants.removeWhere((t) => t.id == tenant.id);
    AppSnackbar.success('Removed', 'Tenant removed and property set to vacant');
  } catch (_) {
    AppSnackbar.error('Failed', 'Could not remove tenant');
  }
}

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final list = await _tenantRepo.getTenantsForOwner('current_owner');
      tenants.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }
}