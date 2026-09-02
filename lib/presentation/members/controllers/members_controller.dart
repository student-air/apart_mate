// lib/presentation/members/controllers/members_controller.dart

import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersController extends GetxController {
  final isLoading = false.obs;
  final tenants = <TenantModel>[].obs;
  final selectedTab = 0.obs;

  late final IPropertyRepository _propertyRepo;
  late final ITenantRepository _tenantRepo;
  late final IAuthRepository _auth;
  late final IMaintenanceRepository _maintRepo;

  @override
  void onInit() {
    super.onInit();
    _tenantRepo = Get.find<ITenantRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
    _auth = Get.find<IAuthRepository>();
    _maintRepo = Get.find<IMaintenanceRepository>();

    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      selectedTab.value = args['tab'] as int;
    }

    loadMembers();
  }

  void switchTab(int index) => selectedTab.value = index;

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
  final owner = _auth.currentUser;
  if (owner == null) {
    AppSnackbar.error('Not signed in', 'Please sign in again');
    return;
  }

  if (tenant.propertyId.isEmpty) {
    AppSnackbar.error('No property', 'Tenant has no linked property');
    return;
  }

  // ── Property must be owner-managed maintenance ──
  final property = await _propertyRepo.getPropertyById(tenant.propertyId);
  if (property == null) {
    AppSnackbar.error('Property', 'Could not load property');
    return;
  }

  final by = property.maintenanceBy.toLowerCase().trim();
  final isOwnerManaged =
      by == 'property_owner' || by == 'owner';

  if (!isOwnerManaged) {
    AppSnackbar.info(
      'Society maintenance',
      'This unit is managed by the society admin. '
      'Mark paid is not available here.',
    );
    return;
  }

  // ── Already paid this calendar month? ──
  final history = await _maintRepo.getHistoryForProperty(
    tenant.propertyId,
    limit: 12,
  );
  final now = DateTime.now();
  final alreadyPaidThisMonth = history.any(
    (h) =>
        h.year == now.year &&
        h.month == now.month &&
        h.status.toLowerCase() == 'paid',
  );

  if (alreadyPaidThisMonth || tenant.maintenancePaid) {
    AppSnackbar.info(
      'Already paid',
      'Maintenance for this month is already marked paid. '
      'You can mark again after the next month starts.',
    );
    return;
  }

  // ── Confirm — cannot be undone ──
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
                color: AppColors.pastelOrangeBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: AppColors.pastelOrangeIcon,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Mark maintenance paid?',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Mark "${tenant.fullName}" as paid for this month.\n\n'
              'This action cannot be undone. '
              'You can mark paid again only after the next month starts.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.accentGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Confirm paid',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accentGreen,
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
    final amount = property.maintenanceAmount.isNotEmpty
        ? property.maintenanceAmount
        : '0';

    String tenantUserId = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenant.id)
          .get();
      tenantUserId = (doc.data()?['linkedUserId'] as String?) ?? '';
    } catch (_) {}

    // Paid record for THIS month only
    await _maintRepo.markCurrentMonthPaidForProperty(
      propertyId: tenant.propertyId,
      ownerUserId: owner.id,
      tenantUserId: tenantUserId,
      amount: amount,
      tenantName: tenant.fullName,
      propertyLabel: tenant.propertyLabel,
    );

    // Chip for this month (source of truth remains payment doc)
    await _tenantRepo.setMaintenancePaid(tenant.id, paid: true);

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
      'Maintenance paid',
      'Recorded for ${tenant.fullName} this month',
    );
  } catch (e) {
    AppSnackbar.error('Failed', e.toString());
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
    } catch (e) {
      AppSnackbar.error('Failed', e.toString());
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
    final now = DateTime.now();
    final updated = <TenantModel>[];

    for (final t in list) {
      var paidThisMonth = false;
      if (t.propertyId.isNotEmpty) {
        final hist = await _maintRepo.getHistoryForProperty(
          t.propertyId,
          limit: 6,
        );
        paidThisMonth = hist.any(
          (h) =>
              h.year == now.year &&
              h.month == now.month &&
              h.status.toLowerCase() == 'paid',
        );
      }

      // Sync flag so menu enables again next month
      if (t.maintenancePaid != paidThisMonth) {
        try {
          await _tenantRepo.setMaintenancePaid(t.id, paid: paidThisMonth);
        } catch (_) {}
      }

      updated.add(
        TenantModel(
          id: t.id,
          fullName: t.fullName,
          phone: t.phone,
          cnic: t.cnic,
          propertyId: t.propertyId,
          propertyLabel: t.propertyLabel,
          inviteCode: t.inviteCode,
          status: t.status,
          createdAt: t.createdAt,
          ownerName: t.ownerName,
          ownerPhone: t.ownerPhone,
          ownerEmail: t.ownerEmail,
          maintenancePaid: paidThisMonth,
        ),
      );
    }

    tenants.assignAll(updated);
  } finally {
    isLoading.value = false;
  }
}
}