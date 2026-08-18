// lib/presentation/property_details/bindings/property_details_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/presentation/property_details/controllers/property_details_controller.dart';

class PropertyDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyDetailsController>(
      () => PropertyDetailsController(
        Get.find<IAuthRepository>(),
        Get.find<IPropertyRepository>(),
      ),
      fenix: true,
    );
  }
}