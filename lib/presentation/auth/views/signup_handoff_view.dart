import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/routes/app_routes.dart';

/// A brief, wordless-ish handoff shown right after a successful Google/Apple
/// signup — "Account created" fades/slides up and out while "Let's set up
/// your society" slides in underneath, then auto-navigates to Society
/// Register. Purely presentational: no controller/binding, self-contained
/// like SplashView.
class SignupHandoffView extends StatefulWidget {
  const SignupHandoffView({super.key});

  @override
  State<SignupHandoffView> createState() => _SignupHandoffViewState();
}

class _SignupHandoffViewState extends State<SignupHandoffView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _layer1Opacity;
  late final Animation<double> _layer1SlideY;
  late final Animation<double> _layer2Opacity;
  late final Animation<double> _layer2SlideY;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)));

    _layer1Opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4375, 0.5875, curve: Curves.easeIn)),
    );
    _layer1SlideY = Tween<double>(begin: 0, end: -24).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4375, 0.5875, curve: Curves.easeIn)),
    );

    _layer2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4875, 0.7375, curve: Curves.easeOut)),
    );
    _layer2SlideY = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4875, 0.7375, curve: Curves.easeOut)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      //if (mounted) Get.offNamed(AppRoutes.societyRegister);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Get.arguments is String ? Get.arguments as String : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _layer1Opacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _layer1SlideY.value),
                      child: _AccountCreatedLayer(scale: _checkScale.value, provider: provider),
                    ),
                  ),
                  Opacity(
                    opacity: _layer2Opacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _layer2SlideY.value),
                      child: const _SetUpSocietyLayer(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AccountCreatedLayer extends StatelessWidget {
  final double scale;
  final String? provider;
  const _AccountCreatedLayer({required this.scale, this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.15), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 34, color: AppColors.successGreenDark),
          ),
        ),
        const SizedBox(height: 16),
        Text('Account created', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          provider != null ? 'Signed in with $provider' : 'Signed in successfully',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SetUpSocietyLayer extends StatelessWidget {
  const _SetUpSocietyLayer();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.villa_rounded, size: 32, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 16),
        Text("Let's set up your society", style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text('Just a few details to get started', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}