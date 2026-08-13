import 'package:get/get.dart';
import 'package:apart_mate/presentation/tenant_confirm/controllers/tenant_confirm_controller.dart';

class TenantConfirmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TenantConfirmController());
  }
}