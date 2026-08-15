import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class MaintenanceController extends GetxController {
  final isLoading = false.obs;
  final monthlyAmount = '0'.obs;
  final history = <MaintenancePaymentModel>[].obs;
  final ownerRows = <MaintenancePaymentModel>[].obs;
  final propertyLabel = ''.obs;

  late final IMaintenanceRepository _maintRepo;
  late final IPropertyRepository _propertyRepo;
  late final IAuthRepository _auth;

  bool get isTenant => AppNavigation.isTenant;

  @override
  void onInit() {
    super.onInit();
    _maintRepo = Get.find<IMaintenanceRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
    _auth = Get.find<IAuthRepository>();
    load();
  }

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      if (isTenant) {
        // TODO: resolve tenant's linked property; for now first occupied demo
        final props = await _propertyRepo.getPropertiesForUser(user.id);
        PropertyModel? property = props.isNotEmpty ? props.first : null;
        // If tenant has no owned props, still stub — wire real link later
        if (property == null) {
          monthlyAmount.value = '0';
          history.clear();
          return;
        }
        propertyLabel.value =
            'Flat ${property.flatNumber} · ${property.building}';
        final amount =
            await _maintRepo.getMonthlyAmountForProperty(property.id);
        monthlyAmount.value = amount;

        await _maintRepo.ensureCurrentMonthPending(
          propertyId: property.id,
          tenantUserId: user.id,
          ownerUserId: property.userId,
          amount: amount,
        );
        history.assignAll(
          await _maintRepo.getHistoryForProperty(property.id, limit: 3),
        );
      } else {
        ownerRows.assignAll(await _maintRepo.getOwnerOverview(user.id));
      }
    } finally {
      isLoading.value = false;
    }
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
    return names[month];
  }
}