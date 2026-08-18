// lib/core/bindings/initial_binding.dart

import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/data/repositories/Firebase_complaint_repository.dart';
import 'package:apart_mate/data/repositories/local_maintenance_repository.dart';
import 'package:apart_mate/data/repositories/firebase_tenant_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/data/repositories/firebase_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/data/repositories/firebase_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/data/repositories/firebase_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/data/repositories/firebase_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_update_repository.dart';
import 'package:apart_mate/data/repositories/firebase_update_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/data/repositories/local_manager_repository.dart';

class InitialBinding extends Bindings {
  @override 
  void dependencies() {
    Get.put<IAuthRepository>(FirebaseAuthRepository(), permanent: true);
    Get.put<IProfileRepository>(FirebaseProfileRepository(), permanent: true);
    Get.put<ISocietyRepository>(FirebaseSocietyRepository(), permanent: true);
    Get.put<IPropertyRepository>(FirebasePropertyRepository(), permanent: true);
    Get.put<IUpdateRepository>(FirebaseUpdateRepository(), permanent: true);
    Get.put<ITenantRepository>(FirebaseTenantRepository(), permanent: true);
    Get.put<IManagerRepository>(LocalManagerRepository(), permanent: true);
    Get.put<IComplaintRepository>(FirebaseComplaintRepository(), permanent: true);
    Get.put<IMaintenanceRepository>(LocalMaintenanceRepository(), permanent: true);
    Get.put(AppSession(), permanent: true);
  }
}