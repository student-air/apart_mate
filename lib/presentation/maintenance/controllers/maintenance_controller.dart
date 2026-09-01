import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
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

  /// Current month paid? (tenant card green)
  bool get isCurrentMonthPaid {
    final now = DateTime.now();
    final list = isTenant ? history : ownerRows;
    return list.any(
      (h) =>
          h.year == now.year &&
          h.month == now.month &&
          h.status == 'paid',
    );
  }

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

    // Do not overwrite a paid doc with pending
    final hist =
        await _maintRepo.getHistoryForProperty(property.id, limit: 6);
    final now = DateTime.now();
    final hasCurrent = hist.any(
      (h) => h.year == now.year && h.month == now.month,
    );
    if (!hasCurrent) {
      await _maintRepo.ensureCurrentMonthPending(
        propertyId: property.id,
        tenantUserId: userId,
        ownerUserId: property.userId,
        amount: monthlyAmount.value,
      );
    }

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

    if (focusList.isNotEmpty) {
      final p = focusList.first;
      monthlyAmount.value =
          p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '0';
      propertyLabel.value =
          'Flat ${p.flatNumber} · ${p.building} · ${p.floor}';
    } else {
      monthlyAmount.value = '0';
      propertyLabel.value = '';
    }

    ownerRows.assignAll(await _maintRepo.getOwnerOverview(userId));
  }

  Future<void> markPaid(String paymentId) async {
    await _maintRepo.markPaid(paymentId);
    await load();
  }

  String monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return names[month];
  }
}