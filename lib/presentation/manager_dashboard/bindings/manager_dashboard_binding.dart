import 'package:get/get.dart';
import 'package:apart_mate/presentation/manager_dashboard/controllers/manager_dashboard_controller.dart';

class ManagerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerDashboardController>(
      () => ManagerDashboardController(),
    );
  }
}