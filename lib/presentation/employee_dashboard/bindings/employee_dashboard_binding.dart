// lib/presentation/employee_dashboard/bindings/employee_dashboard_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/presentation/employee_dashboard/controllers/employee_dashboard_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDashboardController>(
      () => EmployeeDashboardController(),
    );
  }
}