// lib/routes/app_pages.dart

import 'package:apart_mate/presentation/add_tenant/bindings/add_tenant_binding.dart';
import 'package:apart_mate/presentation/add_tenant/views/add_tenant_view.dart';
import 'package:get/get.dart';
import 'package:apart_mate/routes/app_routes.dart';

import 'package:apart_mate/presentation/splash/bindings/splash_binding.dart';
import 'package:apart_mate/presentation/splash/views/splash_view.dart';
import 'package:apart_mate/presentation/auth/bindings/auth_binding.dart';
import 'package:apart_mate/presentation/auth/views/login_view.dart';
import 'package:apart_mate/presentation/auth/views/signup_view.dart';
import 'package:apart_mate/presentation/auth/views/signup_handoff_view.dart';
import 'package:apart_mate/presentation/profile_setup/bindings/profile_setup_binding.dart';
import 'package:apart_mate/presentation/profile_setup/views/profile_setup_view.dart';
import 'package:apart_mate/presentation/role_selection/bindings/role_selection_binding.dart';
import 'package:apart_mate/presentation/role_selection/views/role_selection_view.dart';
import 'package:apart_mate/presentation/join_society/bindings/join_society_binding.dart';
import 'package:apart_mate/presentation/join_society/views/join_society_view.dart';
import 'package:apart_mate/presentation/property_details/bindings/property_details_binding.dart';
import 'package:apart_mate/presentation/property_details/views/property_details_view.dart';

// TODO: uncomment as each module's binding/view is built
import 'package:apart_mate/presentation/request_status/bindings/request_status_binding.dart';
import 'package:apart_mate/presentation/request_status/views/request_status_view.dart';
import 'package:apart_mate/presentation/dashboard/bindings/dashboard_binding.dart';
import 'package:apart_mate/presentation/dashboard/views/dashboard_view.dart';
import 'package:apart_mate/presentation/profile/bindings/profile_binding.dart';
import 'package:apart_mate/presentation/profile/views/profile_view.dart';
import 'package:apart_mate/presentation/updates/bindings/updates_binding.dart';
import 'package:apart_mate/presentation/updates/views/updates_view.dart';
import 'package:apart_mate/presentation/manage_properties/bindings/manage_properties_binding.dart';
import 'package:apart_mate/presentation/manage_properties/views/manage_properties_view.dart';
import 'package:apart_mate/presentation/members/bindings/members_binding.dart';
import 'package:apart_mate/presentation/members/views/members_view.dart';

// import 'package:apart_mate/presentation/edit_profile/bindings/edit_profile_binding.dart';
// import 'package:apart_mate/presentation/edit_profile/views/edit_profile_view.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signupHandoff,
      page: () => const SignupHandoffView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: ProfileSetupBinding(),
    ),
GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.joinSociety,
      page: () => const JoinSocietyView(),
      binding: JoinSocietyBinding(),
    ),
    GetPage(
      name: AppRoutes.propertyDetails,
      page: () => const PropertyDetailsView(),
      binding: PropertyDetailsBinding(),
    ),
    // TODO: register as each module is built
    GetPage(
      name: AppRoutes.updates,
      page: () => const UpdatesView(),
      binding: UpdatesBinding(),
    ),
    GetPage(
      name: AppRoutes.requeststatus,
      page: () => const requeststatusView(),
      binding: requeststatusBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.manageProperties,
      page: () => const ManagePropertiesView(),
      binding: ManagePropertiesBinding(),
    ),
    GetPage(
      name: AppRoutes.addTenant,
      page: () => const AddTenantView(),
      binding: AddTenantBinding(),
    ),
    GetPage(
      name: AppRoutes.members,
      page: () => const MembersView(),
      binding: MembersBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.editProfile,
    //   page: () => const EditProfileView(),
    //   binding: EditProfileBinding(),
    // ),
  ];
}