// lib/routes/app_routes.dart

abstract class AppRoutes {
  AppRoutes._();

  // Splash
  static const splash = '/splash';

  // Auth
  static const login = '/login';
  static const signup = '/signup';
  static const signupHandoff = '/signup-handoff';

  // Onboarding flow
  static const profileSetup = '/profile-setup';
  static const roleSelection = '/role-selection';
  static const joinSociety = '/join-society';
  static const propertyDetails = '/property-details';
  static const requeststatus = '/request-status';

  // Main app
  static const dashboard = '/dashboard';
  static const manageProperties = '/manage-properties';
  static const updates = '/updates';
  static const addTenant = '/add-tenant';
  static const addManager = '/add-manager';
  static const members = '/members';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
}