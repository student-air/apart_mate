import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/data/repositories/firebase_tenant_repository.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersController extends GetxController {
  final isLoading = false.obs;
  final tenants = <TenantModel>[].obs;
  final selectedTab = 0.obs; // 0 = Tenants, 1 = Managers

  late final IPropertyRepository _propertyRepo;
  late final ITenantRepository _tenantRepo;
  late final IAuthRepository _auth;

  @override
  void onInit() {
    super.onInit();
    _tenantRepo = Get.find<ITenantRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
    _auth = Get.find<IAuthRepository>();

    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      selectedTab.value = args['tab'] as int;
    }

    loadMembers();
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppSnackbar.success('Copied', 'Invite code copied');
  }

  Future<void> callTenant(TenantModel tenant) async {
    final cleaned = tenant.phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      AppSnackbar.info('No phone', 'Tenant has no phone number');
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Call failed', 'Could not open phone dialer');
    }
  }

  Future<void> markMaintenancePaid(TenantModel tenant) async {
    if (tenant.maintenancePaid) {
      AppSnackbar.info('Already paid', 'Maintenance is already marked paid');
      return;
    }

    try {
      final repo = _tenantRepo;
      if (repo is FirebaseTenantRepository) {
        await repo.setMaintenancePaid(tenant.id, paid: true);
      } else {
        // fallback: merge via save if you only have saveTenant
        await repo.saveTenant(
          TenantModel(
            id: tenant.id,
            fullName: tenant.fullName,
            phone: tenant.phone,
            cnic: tenant.cnic,
            propertyId: tenant.propertyId,
            propertyLabel: tenant.propertyLabel,
            inviteCode: tenant.inviteCode,
            status: tenant.status,
            createdAt: tenant.createdAt,
            ownerName: tenant.ownerName,
            ownerPhone: tenant.ownerPhone,
            ownerEmail: tenant.ownerEmail,
            maintenancePaid: true,
          ),
        );
      }

      final i = tenants.indexWhere((e) => e.id == tenant.id);
      if (i != -1) {
        tenants[i] = TenantModel(
          id: tenant.id,
          fullName: tenant.fullName,
          phone: tenant.phone,
          cnic: tenant.cnic,
          propertyId: tenant.propertyId,
          propertyLabel: tenant.propertyLabel,
          inviteCode: tenant.inviteCode,
          status: tenant.status,
          createdAt: tenant.createdAt,
          ownerName: tenant.ownerName,
          ownerPhone: tenant.ownerPhone,
          ownerEmail: tenant.ownerEmail,
          maintenancePaid: true,
        );
        tenants.refresh();
      }

      AppSnackbar.success(
        'Maintenance',
        'Marked as paid for ${tenant.fullName}',
      );
    } catch (_) {
      AppSnackbar.error('Failed', 'Could not update maintenance');
    }
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
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
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
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
        final property =
            await _propertyRepo.getPropertyById(tenant.propertyId);
        if (property != null) {
          await _propertyRepo.saveProperty(
            property.copyWith(isOccupied: false, occupiedBy: ''),
          );
        }
      }

      tenants.removeWhere((t) => t.id == tenant.id);
      AppSnackbar.success(
        'Removed',
        'Tenant removed and property set to vacant',
      );
    } catch (_) {
      AppSnackbar.error('Failed', 'Could not remove tenant');
    }
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final owner = _auth.currentUser;
      if (owner == null) {
        tenants.clear();
        return;
      }
      final list = await _tenantRepo.getTenantsForOwner(owner.id);
      tenants.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }
}