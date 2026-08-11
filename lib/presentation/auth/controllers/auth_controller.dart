import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/validators.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepository;
  AuthController(this._authRepository);

  // Login
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isPasswordVisible = false.obs;

  // Signup
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isSignupPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isResettingPassword = false.obs;

  final isLoading = false.obs;
  final loginShakeTrigger = 0.obs;
  final loginError = RxnString();

  final signupShakeTrigger = 0.obs;
  final emailError = RxnString();
  final phoneError = RxnString();

  @override
  void onInit() {
    super.onInit();
    emailCtrl.addListener(() => emailError.value = null);
    phoneCtrl.addListener(() => phoneError.value = null);
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleSignupPasswordVisibility() => isSignupPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  /// Routes the user to onboarding (new account) or straight to the
  /// dashboard (returning account) after any successful auth action.
  Future<void> _navigateAfterAuth({bool isNewUser = false}) async {
    if (isNewUser) {
      Get.offAllNamed(AppRoutes.profileSetup);
    } else {
      AppSnackbar.success('Login successful', 'Welcome back!');
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  bool _isCancelled(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('aborted-by-user') ||
        msg.contains('canceled') ||
        msg.contains('cancelled');
  }

  Future<void> login() async {
    if (usernameCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
      loginError.value = 'Please enter your username and password';
      loginShakeTrigger.value++;
      return;
    }
    isLoading.value = true;
    try {
      await _authRepository.login(
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      loginError.value = null;
      await _navigateAfterAuth();
    } catch (_) {
      loginError.value = 'Incorrect username or password';
      loginShakeTrigger.value++;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authRepository.loginWithGoogle();
      await _navigateAfterAuth(isNewUser: result.isNewUser);
    } catch (e) {
      if (_isCancelled(e)) return;
      AppSnackbar.error('Google sign-in failed', 'Please try again');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      final result = await _authRepository.loginWithApple();
      await _navigateAfterAuth(isNewUser: result.isNewUser);
    } catch (e) {
      if (_isCancelled(e)) return;
      AppSnackbar.error('Apple sign-in failed', 'Please try again');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithGoogle() async {
  isLoading.value = true;
  try {
    await _authRepository.loginWithGoogle();
    Get.offNamed(AppRoutes.signupHandoff, arguments: 'Google');
  } catch (e) {
    if (!_isCancelled(e)) {
      AppSnackbar.error('Google sign-in failed', 'Please try again');
    }
  } finally {
    isLoading.value = false;
  }
}

Future<void> signUpWithApple() async {
  isLoading.value = true;
  try {
    await _authRepository.loginWithApple();
    Get.offNamed(AppRoutes.signupHandoff, arguments: 'Apple');
  } catch (e) {
    if (!_isCancelled(e)) {
      AppSnackbar.error('Apple sign-in failed', 'Please try again');
    }
  } finally {
    isLoading.value = false;
  }
}

  Future<void> forgotPassword() async {
    final resetEmailCtrl = TextEditingController(text: usernameCtrl.text.trim());
    final result = await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reset password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the email for your account. We\'ll send a reset link.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@gmail.com',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: resetEmailCtrl.text.trim()),
                  child: const Text('Send reset link'),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    isResettingPassword.value = true;
    try {
      await _authRepository.sendPasswordResetEmail(result);
      AppSnackbar.success('Email sent', 'Check $result for a password reset link');
    } catch (e) {
      AppSnackbar.error('Reset failed', e.toString());
    } finally {
      isResettingPassword.value = false;
    }
  }

  Future<void> signUp() async {
    if (fullNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        signupPasswordCtrl.text.isEmpty) {
      signupShakeTrigger.value++;
      AppSnackbar.error('Missing info', 'Please fill in all required fields');
      return;
    }
    if (!Validators.isValidEmail(emailCtrl.text)) {
      emailError.value = 'Enter a valid email address';
      return;
    }
    if (!Validators.isValidPhone(phoneCtrl.text)) {
      phoneError.value = 'Use format 03XXXXXXXXX or +92 3XX XXXXXXX';
      return;
    }
    if (signupPasswordCtrl.text != confirmPasswordCtrl.text) {
      AppSnackbar.error('Password mismatch', 'Passwords do not match');
      return;
    }
    final passwordError = Validators.passwordErrorMessage(signupPasswordCtrl.text);
    if (passwordError != null) {
      AppSnackbar.error('Weak password', passwordError);
      return;
    }
    isLoading.value = true;
    try {
      await _authRepository.signUp(
        fullName: fullNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: signupPasswordCtrl.text,
      );
      Get.offNamed(AppRoutes.signupHandoff, arguments: 'Email');
    } catch (e) {
      AppSnackbar.error('Sign up failed', 'Please try again');
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(AppRoutes.signup);
  void goToLogin() => Get.toNamed(AppRoutes.login);

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    signupPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}