import 'package:get/get.dart';
import 'package:apart_mate/presentation/add_manager/controllers/add_manager_controller.dart';

class AddManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddManagerController());
  }
}