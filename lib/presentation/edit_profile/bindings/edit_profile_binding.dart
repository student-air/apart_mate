import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/presentation/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(
        Get.find<IAuthRepository>(),
        Get.find<IProfileRepository>(),
      ),
    );
  }
}