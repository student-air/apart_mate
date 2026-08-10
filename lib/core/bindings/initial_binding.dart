// lib/core/bindings/initial_binding.dart

import 'package:get/get.dart';

import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/data/repositories/local_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/data/repositories/local_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/data/repositories/local_property_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IAuthRepository>(LocalAuthRepository(), permanent: true);
    Get.put<IProfileRepository>(LocalProfileRepository(), permanent: true);
    Get.put<ISocietyRepository>(LocalSocietyRepository(), permanent: true);
    Get.put<IPropertyRepository>(LocalPropertyRepository(), permanent: true);
  }
}