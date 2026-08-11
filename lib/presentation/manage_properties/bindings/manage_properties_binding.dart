// lib/presentation/manage_properties/bindings/manage_properties_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/presentation/manage_properties/controllers/manage_properties_controller.dart';

class ManagePropertiesBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard must already exist (opened from Home).
    // If not registered, ManagePropertiesController will fail on Get.find.
    if (!Get.isRegistered<DashboardController>()) {
      // You came from a path where dashboard wasn't created.
      // Prefer opening this screen only from the dashboard.
      // Optionally register dashboard here if you have its deps available.
    }

    Get.lazyPut<ManagePropertiesController>(
      () => ManagePropertiesController(),
    );
  }
}