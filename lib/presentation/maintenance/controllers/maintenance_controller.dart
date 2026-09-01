// lib/presentation/maintenance/controllers/maintenance_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class MaintenanceController extends GetxController {
  final isLoading = false.obs;
  final monthlyAmount = '0'.obs;
  final history = <MaintenancePaymentModel>[].obs;
  final ownerRows = <MaintenancePaymentModel>[].obs;
  final propertyLabel = ''.obs;

  late final IMaintenanceRepository _maintRepo;
  late final IPropertyRepository _propertyRepo;
  late final ITenantRepository _tenantRepo;
  late final IAuthRepository _auth;

  bool get isTenant => AppNavigation.isTenant;

  @override
  void onInit() {
    super.onInit();
    _maintRepo = Get.find<IMaintenanceRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
    _tenantRepo = Get.find<ITenantRepository>();
    _auth = Get.find<IAuthRepository>();
    load();
  }

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      if (isTenant) {
        await _loadTenant(user.id);
      } else {
        await _loadOwner(user.id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTenant(String userId) async {
    final tenant = await _tenantRepo.getTenantForUser(userId);
    if (tenant == null || tenant.propertyId.isEmpty) {
      monthlyAmount.value = '0';
      propertyLabel.value = '';
      history.clear();
      return;
    }

    final property = await _propertyRepo.getPropertyById(tenant.propertyId);
    if (property == null) {
      monthlyAmount.value = '0';
      propertyLabel.value = tenant.propertyLabel;
      history.clear();
      return;
    }

    propertyLabel.value =
        'Flat ${property.flatNumber} · ${property.building} · ${property.floor}';

    final amount = await _maintRepo.getMonthlyAmountForProperty(property.id);
    monthlyAmount.value = amount.isEmpty ? '0' : amount;

    await _maintRepo.ensureCurrentMonthPending(
      propertyId: property.id,
      tenantUserId: userId,
      ownerUserId: property.userId,
      amount: monthlyAmount.value,
    );

    history.assignAll(
      await _maintRepo.getHistoryForProperty(property.id, limit: 6),
    );
  }

  Future<void> _loadOwner(String userId) async {
    final props = await _propertyRepo.getPropertiesForUser(userId);

    final managed = props.where((p) {
      final by = p.maintenanceBy.toLowerCase();
      return by == 'property_owner' || by == 'owner';
    }).toList();

    final focusList = managed.isNotEmpty ? managed : props;

    if (focusList.isEmpty) {
      monthlyAmount.value = '0';
      propertyLabel.value = '';
      ownerRows.clear();
      return;
    }

    final primary = focusList.first;
    monthlyAmount.value = primary.maintenanceAmount.isNotEmpty
        ? primary.maintenanceAmount
        : '0';
    propertyLabel.value =
        'Flat ${primary.flatNumber} · ${primary.building} · ${primary.floor}';

    // Seed current-month pending for each unit with an amount
    final myTenants = await _tenantRepo.getTenantsForOwner(userId);

    for (final p in focusList) {
      final amount =
          p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '0';
      if (amount == '0') continue;

      final linked = myTenants.where((t) => t.propertyId == p.id).toList();
      final tenantUserId = linked.isNotEmpty
          ? (linked.first.id) // fallback; prefer linkedUserId if you store it
          : '';

      await _maintRepo.ensureCurrentMonthPending(
        propertyId: p.id,
        tenantUserId: tenantUserId,
        ownerUserId: userId,
        amount: amount,
      );
    }

    ownerRows.assignAll(await _maintRepo.getOwnerOverview(userId));
  }

  Future<void> markPaid(String paymentId) async {
    if (paymentId.isEmpty) return;
    await _maintRepo.markPaid(paymentId);
    await load();
  }

  String monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return names[month];
  }
}