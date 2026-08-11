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
  static const requestStatus = '/request-status';

  // Main app
  static const dashboard = '/dashboard';
  static const updates = '/updates';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
}