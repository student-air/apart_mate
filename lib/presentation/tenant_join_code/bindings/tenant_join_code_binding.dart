import 'package:get/get.dart';
import 'package:apart_mate/presentation/tenant_join_code/controllers/tenant_join_code_controller.dart';

class TenantJoinCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TenantJoinCodeController());
  }
}