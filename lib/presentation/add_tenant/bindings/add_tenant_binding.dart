// lib/presentation/add_tenant/bindings/add_tenant_binding.dart
import 'package:get/get.dart';
import 'package:apart_mate/presentation/add_tenant/controllers/add_tenant_controller.dart';

class AddTenantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddTenantController());
  }
}