// lib/presentation/dashboard/bindings/dashboard_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        Get.find<IAuthRepository>(),
        Get.find<ISocietyRepository>(),
        Get.find<IPropertyRepository>(),
      ),
    );
  }
}