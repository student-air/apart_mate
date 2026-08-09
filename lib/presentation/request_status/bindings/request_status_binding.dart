// lib/presentation/request_status/bindings/request_status_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/request_status/controllers/request_status_controller.dart';

class RequestStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestStatusController>(
      () => RequestStatusController(
        Get.find<IAuthRepository>(),
        Get.find<ISocietyRepository>(),
        Get.find<IPropertyRepository>(),
      ),
    );
  }
}