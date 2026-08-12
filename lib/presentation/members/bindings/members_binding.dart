import 'package:get/get.dart';
import 'package:apart_mate/presentation/members/controllers/members_controller.dart';

class MembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MembersController());
  }
}