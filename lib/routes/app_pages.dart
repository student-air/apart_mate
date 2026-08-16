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
import 'package:apart_mate/presentation/add_tenant/bindings/add_tenant_binding.dart';
import 'package:apart_mate/presentation/add_tenant/views/add_tenant_view.dart';
import 'package:apart_mate/presentation/add_manager/bindings/add_manager_binding.dart';
import 'package:apart_mate/presentation/add_manager/views/add_manager_view.dart';
import 'package:apart_mate/presentation/tenant_join_code/bindings/tenant_join_code_binding.dart';
import 'package:apart_mate/presentation/tenant_join_code/views/tenant_join_code_view.dart';
import 'package:apart_mate/presentation/tenant_confirm/bindings/tenant_confirm_binding.dart';
import 'package:apart_mate/presentation/tenant_confirm/views/tenant_confirm_view.dart';
import 'package:apart_mate/presentation/tenant_dashboard/bindings/tenant_dashboard_binding.dart';
import 'package:apart_mate/presentation/tenant_dashboard/views/tenant_dashboard_view.dart';
import 'package:apart_mate/presentation/maintenance/bindings/maintenance_binding.dart';
import 'package:apart_mate/presentation/maintenance/views/maintenance_view.dart';
import 'package:apart_mate/presentation/complaint/bindings/complaint_binding.dart';
import 'package:apart_mate/presentation/complaint/views/complaint_view.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
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
      name: AppRoutes.updates,
      page: () => const UpdatesView(),
      binding: UpdatesBinding(),
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
    GetPage(
      name: AppRoutes.addManager,
      page: () => const AddManagerView(),
      binding: AddManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.tenantJoinCode,
      page: () => const TenantJoinCodeView(),
      binding: TenantJoinCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.tenantConfirm,
      page: () => const TenantConfirmView(),
      binding: TenantConfirmBinding(),
    ),
    GetPage(
      name: AppRoutes.tenantDashboard,
      page: () => const TenantDashboardView(),
      binding: TenantDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.maintenance,
      page: () => const MaintenanceView(),
      binding: MaintenanceBinding(),
    ),
    GetPage(
      name: AppRoutes.complaint,
      page: () => const ComplaintView(),
      binding: ComplaintBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}