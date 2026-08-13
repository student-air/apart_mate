import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

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

  Future<void> continueToDashboard() async {
    isLoading.value = true;
    try {
      // Mark invitation as joined
      await _tenantRepo.saveTenant(
        TenantModel(
          id: tenant.id,
          fullName: tenant.fullName,
          phone: tenant.phone,
          cnic: tenant.cnic,
          propertyId: tenant.propertyId,
          propertyLabel: tenant.propertyLabel,
          inviteCode: tenant.inviteCode,
          status: 'joined',
          createdAt: tenant.createdAt,
        ),
      );

      AppSnackbar.success('Welcome', 'You’re all set as a tenant');
      Get.offAllNamed(AppRoutes.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back();
}