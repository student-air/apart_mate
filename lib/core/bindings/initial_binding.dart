// lib/core/bindings/initial_binding.dart

import 'package:get/get.dart';

import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';

// TODO: uncomment as each repository is built
 import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
 import 'package:apart_mate/data/repositories/local_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/data/repositories/local_society_repository.dart';
// import 'package:apart_mate/domain/repositories/i_property_repository.dart';
// import 'package:apart_mate/data/repositories/local/local_property_repository.dart';
// import 'package:apart_mate/domain/repositories/i_request_repository.dart';
// import 'package:apart_mate/data/repositories/local/local_request_repository.dart';
// import 'package:apart_mate/domain/repositories/i_dashboard_repository.dart';
// import 'package:apart_mate/data/repositories/local/local_dashboard_repository.dart';

/// Wires every repository interface to its concrete implementation once,
/// at app start. Screens/controllers only ever depend on the `I*Repository`
/// interfaces — swapping local -> firebase later means changing only this
/// file, not any controller or view.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IAuthRepository>(LocalAuthRepository(), permanent: true);
    Get.put<IProfileRepository>(LocalProfileRepository(), permanent: true);
    Get.put<ISocietyRepository>(LocalSocietyRepository(), permanent: true);
    // TODO: register as each repository is built
    
    // Get.put<IPropertyRepository>(LocalPropertyRepository(), permanent: true);
    // Get.put<IRequestRepository>(LocalRequestRepository(), permanent: true);
    // Get.put<IDashboardRepository>(LocalDashboardRepository(), permanent: true);
  }
}