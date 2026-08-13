import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';

class TenantDashboardController extends GetxController {
  String get userName {
    final auth = Get.find<IAuthRepository>();
    return auth.currentUser?.fullName ?? '';
  }

  String get roleLabel => 'Tenant';

  String get societyName {
    if (Get.isRegistered<DashboardController>()) {
      return Get.find<DashboardController>().society.value?.name ?? '';
    }
    return '';
  }
}