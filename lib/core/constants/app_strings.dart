// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────────────
  static const appName = 'Apart Mate';
  static const appTagline = 'Management at Your Fingertips';
  static const tapToContinue = 'Tap to continue';
  static const appVersion = 'v1.0.0';

  // ── Auth - Login ─────────────────────────────────────
  static const welcomeBack = 'Welcome Back';
  static const signInSubtitle = 'Sign in to manage your property with ease';
  static const username = 'Username';
  static const usernameHint = 'Enter your username';
  static const password = 'Password';
  static const passwordHint = 'Enter your password';
  static const forgotPassword = 'Forgot Password?';
  static const login = 'Login';
  static const or = 'OR';
  static const continueWithGoogle = 'Continue with Google';
  static const continueWithApple = 'Continue with Apple';
  static const noAccount = "Don't have an account? ";
  static const signUp = 'Sign Up';

  // ── Auth - Signup ────────────────────────────────────
  static const createAccount = 'Create Account';
  static const signUpSubtitle = 'Join apart_mate as a resident or owner ';
  static const fullName = 'Full Name';
  static const fullNameHint = 'e.g. John Doe';
  static const email = 'Email';
  static const emailHint = 'Enter your email';
  static const phoneNumber = 'Phone Number';
  static const phoneHint = 'e.g. +92 300 1234567';
  static const createPasswordHint = 'Create a strong password';
  static const confirmPassword = 'Confirm Password';
  static const confirmPasswordHint = 'Re-enter your password';
  static const register = 'Register';
  static const alreadyHaveAccount = 'Already have an account? ';
  static const cnic = 'CNIC';
  static const cnicHint = 'e.g. 35202-1234567-8';
  static const city = 'City';
  static const cityHint = 'Select city';
  static const country = 'Country';
  static const countryHint = 'Select country';
  static const contactNumber = 'Contact Number';
  static const contactNumberHint = '+92 300 1234567';
  static const descriptionOptional = 'Description (Optional)';
  static const descriptionHint = 'Brief description about...';

  // ── Common ───────────────────────────────────────────
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const save = 'Save';
  static const done = 'Done';
  static const retry = 'Retry';
  static const viewAll = 'View All';
  static const comingSoon = 'Coming soon';

  // ── Dashboard ────────────────────────────────────────
  static const goodMorning = 'Good Morning';
  static const goodAfternoon = 'Good Afternoon';
  static const goodEvening = 'Good Evening';
  static const owner = 'Owner';
  static const tenant = 'Tenant';
  static const todaysDate = "Today's Date";
  static const quickActions = 'Quick Actions';
  static const propertyDetails = 'Property Details';
  static const latestUpdates = 'Latest Updates';
  static const noUpdatesYet = 'No updates yet';
  static const noPropertyFound = 'No property found on your account yet.';

  // ── My Properties ────────────────────────────────────
  static const myProperties = 'My Properties';
  static const edit = 'Edit';
  static const active = 'Active';
  static const occupied = 'Occupied';
  static const vacant = 'Vacant';
  static const deletePropertyTitle = 'Delete property?';
  static String deletePropertyMessage(String flat) =>
      'This will permanently remove "Flat $flat" from the list.';
  static const propertyDeleted = 'Deleted';
  static String propertyDeletedMessage(String flat) =>
      'Flat $flat has been permanently removed';

  // ── Add Tenant ───────────────────────────────────────
  static const addTenant = 'Add Tenant';
  static const addTenantSubtitle = 'Invite a tenant to your property';
  static const tenantDetails = 'Tenant Details';
  static const tenantDetailsSubtitle = 'Enter the tenant’s basic information';
  static const selectVacantProperty = 'Select Vacant Property';
  static const onlyVacantShown = 'Only vacant properties are shown';
  static const noVacantProperties = 'No vacant properties available';
  static const saveTenant = 'Save Tenant';
  static const tenantAdded = 'Tenant Added!';
  static String shareCodeWith(String name) => 'Share this code with $name';
  static const tenantWillUseCode = 'Tenant will use this code to join';
  static const missingFields = 'Please fill all fields';
  static const selectProperty = 'Please select a vacant property';

  // ── Drawer ───────────────────────────────────────────
  static const home = 'Home';
  static const updates = 'Updates';
  static const requests = 'Requests';
  static const myProperty = 'My Property';
  static const documents = 'Documents';
  static const maintenance = 'Maintenance';
  static const complaints = 'Complaints';
  static const contactAdmin = 'Contact Admin';
  static const profile = 'Profile';
  static const settings = 'Settings';
  static const logout = 'Logout';
  static const switchToTenant = 'Switch to Tenant';
  static const switchToOwner = 'Switch to Owner';

  static const occupationHint = 'e.g. Engineer, Doctor...';

  static String managerDetails = 'Manager Details';

  static String managerDetailsSubtitle = 'Enter the manager’s basic information';

  static String addManagerSubtitle = 'Invite a manager to your property';

  static String addManager = 'Add Manager';

  static String saveManager = 'Save Manager';

  static String managerWillUseCode = 'Manager will use this code to join';

  static String managerAdded = 'Manager Added!';
}