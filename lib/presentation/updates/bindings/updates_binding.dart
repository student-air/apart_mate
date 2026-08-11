import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_update_repository.dart';
import 'package:apart_mate/presentation/updates/controllers/updates_controller.dart';

class UpdatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdatesController>(
      () => UpdatesController(Get.find<IUpdateRepository>()),
    );
  }
}