import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';

class TenantDashboardController extends GetxController {
  final isLoading = false.obs;

  late final TenantModel tenant;
  late final PropertyModel property;

  String get userName => tenant.fullName;
  String get firstName {
    final parts = userName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'Tenant';
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get roleLabel => 'Tenant';

  String get propertyLabel =>
      tenant.propertyLabel.isNotEmpty
          ? tenant.propertyLabel
          : 'Flat ${property.flatNumber}';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null &&
        args['tenant'] is TenantModel &&
        args['property'] is PropertyModel) {
      tenant = args['tenant'] as TenantModel;
      property = args['property'] as PropertyModel;
    } else {
      // Fallback if opened without args (e.g. from nav)
      tenant = TenantModel(
        id: '',
        fullName: 'Tenant',
        phone: '',
        cnic: '',
        propertyId: '',
        propertyLabel: '',
        inviteCode: '',
        status: 'joined',
        createdAt: DateTime.now(),
      );
      property = PropertyModel(
        id: '',
        userId: '',
        societyId: '',
        building: '',
        floor: '',
        flatNumber: '—',
        isOccupied: true,
        occupiedBy: '',
        propertyType: '',
        areaSqFt: '',
        bathrooms: '',
        flatType: '',
        hasBalcony: false,
        hasElectricity: false,
        hasGas: false,
        meterType: '',
        waterConnection: '',
        furnishing: '',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isLoading.value = false;
  }
}