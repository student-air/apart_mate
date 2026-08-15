import 'package:get/get.dart';
import 'package:apart_mate/presentation/maintenance/controllers/maintenance_controller.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaintenanceController());
  }
}