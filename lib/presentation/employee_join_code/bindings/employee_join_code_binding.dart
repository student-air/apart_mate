// lib/presentation/employee_join_code/bindings/employee_join_code_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/presentation/employee_join_code/controllers/employee_join_code_controller.dart';

class EmployeeJoinCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeJoinCodeController>(
      () => EmployeeJoinCodeController(),
    );
  }
}