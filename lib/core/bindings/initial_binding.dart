// lib/core/bindings/initial_binding.dart

import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/data/repositories/local_complaint_repository.dart';
import 'package:apart_mate/data/repositories/local_maintenance_repository.dart';
import 'package:apart_mate/data/repositories/local_tenant_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/data/repositories/local_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/data/repositories/local_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/data/repositories/local_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_update_repository.dart';
import 'package:apart_mate/data/repositories/local_update_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/data/repositories/local_manager_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IAuthRepository>(LocalAuthRepository(), permanent: true);
    Get.put<IProfileRepository>(LocalProfileRepository(), permanent: true);
    Get.put<ISocietyRepository>(LocalSocietyRepository(), permanent: true);
    Get.put<IPropertyRepository>(LocalPropertyRepository(), permanent: true);
    Get.put<IUpdateRepository>(LocalUpdateRepository(), permanent: true);
    Get.put<ITenantRepository>(LocalTenantRepository(), permanent: true);
    Get.put<IManagerRepository>(LocalManagerRepository(), permanent: true);
    Get.put<IComplaintRepository>(LocalComplaintRepository(), permanent: true);
    Get.put<IMaintenanceRepository>(LocalMaintenanceRepository(), permanent: true);
    Get.put(AppSession(), permanent: true);
  }
}