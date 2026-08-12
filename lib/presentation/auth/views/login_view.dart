import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/core/widgets/app_card.dart';
import 'package:apart_mate/core/widgets/app_text_field.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/presentation/auth/controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimens.headerRadius),
                    bottomRight: Radius.circular(AppDimens.headerRadius),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(AppStrings.welcomeBack, style: AppTextStyles.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.signInSubtitle,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _LoginFormCard(controller: controller),
                ),
              ),
              const SizedBox(height: AppDimens.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.noAccount, style: AppTextStyles.caption),
                  GestureDetector(
                    onTap: controller.goToSignup,
                    child: Text(AppStrings.signUp, style: AppTextStyles.labelLarge),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white card holding the login form fields and buttons.
///
/// Pulled out into its own StatefulWidget (rather than living directly in
/// LoginView, which is a stateless GetView) so it can own a shake
/// AnimationController — it listens to `controller.loginShakeTrigger` and
/// plays a horizontal shake whenever login fails (empty fields today; any
/// real backend rejection once Firebase is wired in, automatically, with
/// zero changes needed here).
class _LoginFormCard extends StatefulWidget {
  final AuthController controller;
  const _LoginFormCard({required this.controller});

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;
  late final Worker _shakeWorker;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _shakeWorker = ever(widget.controller.loginShakeTrigger, (_) {
      _shakeController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _shakeWorker.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: _shakeOffset,
      builder: (context, child) => Transform.translate(offset: Offset(_shakeOffset.value, 0), child: child),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AppStrings.username,
              hint: AppStrings.usernameHint,
              controller: controller.usernameCtrl,
            ),
            const SizedBox(height: AppDimens.space20),
            Obx(
              () => AppTextField(
                label: AppStrings.password,
                hint: AppStrings.passwordHint,
                controller: controller.passwordCtrl,
                obscureText: !controller.isPasswordVisible.value,
                suffixIcon: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            Obx(() {
              final error = controller.loginError.value;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppDimens.space8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                    const SizedBox(width: AppDimens.space4),
                    Expanded(
                      child: Text(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppDimens.space16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => AppSnackbar.error('Forgot password', 'This will be added soon.'),
                child: Text(AppStrings.forgotPassword, style: AppTextStyles.labelLarge),
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Obx(
              () => AppPrimaryButton(
                label: AppStrings.login,
                isLoading: controller.isLoading.value,
                onPressed: controller.login,
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(AppStrings.or, style: AppTextStyles.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppDimens.space24),
            AppSecondaryButton(
              label: AppStrings.continueWithGoogle,
              leading: Text('G', style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF4285F4))),
              onPressed: controller.loginWithGoogle,
            ),
            const SizedBox(height: AppDimens.space12),
            AppSecondaryButton(
              label: AppStrings.continueWithApple,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              borderColor: Colors.black,
              leading: const Icon(Icons.apple, color: Colors.white, size: 22),
              onPressed: controller.loginWithApple,
            ),
          ],
        ),
      ),
    );
  }
}