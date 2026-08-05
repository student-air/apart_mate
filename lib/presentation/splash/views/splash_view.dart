import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/presentation/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ShutterSplash(onComplete: controller.skip),
    );
  }
}

class _ShutterSplash extends StatefulWidget {
  final VoidCallback onComplete;
  const _ShutterSplash({required this.onComplete});

  @override
  State<_ShutterSplash> createState() => _ShutterSplashState();
}

class _ShutterSplashState extends State<_ShutterSplash> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;
  late final AnimationController _hintController;
  late final AnimationController _shutterController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _glow;
  late final Animation<double> _hintPulse;
  late final Animation<Offset> _shutterOffset;

  bool _showHint = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _logoFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _titleFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.75, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.75, curve: Curves.easeOut)),
    );

    _taglineFade = CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut));
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _entranceController.forward();

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _glow = Tween<double>(begin: 0.15, end: 0.4).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _glowController.repeat(reverse: true);

    _hintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _hintPulse = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _hintController, curve: Curves.easeInOut));

    _shutterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _shutterOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _showHint = true);
      _hintController.repeat(reverse: true);
    });
  }

  void _handleTap() {
    if (_isClosing) return;
    setState(() => _isClosing = true);
    _shutterController.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _hintController.dispose();
    _shutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.background)),
        GestureDetector(
          onTap: _handleTap,
          child: SlideTransition(
            position: _shutterOffset,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryDark, AppColors.primaryDarkGradientEnd],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    AnimatedBuilder(
                      animation: Listenable.merge([_entranceController, _glowController]),
                      builder: (context, child) {
                        return SlideTransition(
                          position: _logoSlide,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentGreen.withValues(alpha: _glow.value),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '合',
                                  style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 58),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Text(AppStrings.appName, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          AppStrings.appTagline,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: _showHint ? 1 : 0,
                      child: FadeTransition(
                        opacity: _hintPulse,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_outlined, size: 16, color: AppColors.successGreen.withValues(alpha: 0.6)),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.tapToContinue,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}