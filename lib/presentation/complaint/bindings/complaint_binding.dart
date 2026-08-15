import 'package:get/get.dart';
import 'package:apart_mate/presentation/complaint/controllers/complaint_controller.dart';

class ComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintListController>(() => ComplaintListController());
  }
}