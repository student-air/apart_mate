import 'package:get/get.dart';
import 'package:apart_mate/presentation/tenant_dashboard/controllers/tenant_dashboard_controller.dart';

class TenantDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: recreate after being removed so arguments are read again
    Get.lazyPut(() => TenantDashboardController(), fenix: true);
  }
}