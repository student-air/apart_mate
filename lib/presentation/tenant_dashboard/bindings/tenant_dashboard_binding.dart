import 'package:get/get.dart';
import 'package:apart_mate/presentation/tenant_dashboard/controllers/tenant_dashboard_controller.dart';

class TenantDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TenantDashboardController());
  }
}