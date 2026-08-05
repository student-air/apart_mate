import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'dart:math';

/// Draws a success checkmark stroke-by-stroke, like it's being signed,
/// then loops (pause, reset, redraw) for as long as it stays on screen.
class AppAnimatedCheckmark extends StatefulWidget {
  const AppAnimatedCheckmark({super.key});

  @override
  State<AppAnimatedCheckmark> createState() => _AppAnimatedCheckmarkState();
}

class _AppAnimatedCheckmarkState extends State<AppAnimatedCheckmark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 150), _loop);
  }

  Future<void> _loop() async {
    while (mounted) {
      await _controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, circleScale, child) {
        return Transform.scale(
          scale: circleScale,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.successGreen.withValues(alpha: 0.3), blurRadius: 16)],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(64, 64),
                    painter: _CheckmarkPainter(progress: _controller.value),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  const _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.70)
      ..lineTo(size.width * 0.78, size.height * 0.32);

    final metrics = path.computeMetrics().first;
    final partialPath = metrics.extractPath(0, metrics.length * progress);

    canvas.drawPath(partialPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Wraps any child, spinning + fading + scaling it in after an optional
/// delay — used to stagger a row of icons (e.g. Society/Owner/Location/Contact).
class AppSpinInIcon extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AppSpinInIcon({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<AppSpinInIcon> createState() => _AppSpinInIconState();
}

class _AppSpinInIconState extends State<AppSpinInIcon> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _started ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.4 + (0.6 * t),
            child: Transform.rotate(
              angle: (1 - t) * -3.14159,
              child: widget.child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Scales a child in from nothing with a springy bounce, once, when it
/// first appears — optionally after a delay (for staggering multiple items).
class AppPopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AppPopIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<AppPopIn> createState() => _AppPopInState();
}

class _AppPopInState extends State<AppPopIn> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _started ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: widget.child,
    );
  }
}

/// Fades and slides a child up into place, once, after an optional delay —
/// used to sequence entrances (e.g. title, then description, then a card)
/// instead of everything appearing simultaneously.
class AppFadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AppFadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<AppFadeSlideIn> createState() => _AppFadeSlideInState();
}

class _AppFadeSlideInState extends State<AppFadeSlideIn> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _started ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// A small dot with a soft, looping pulse ring around it — signals "this is
/// live/being tracked," used next to a pending/in-progress status label.
class AppPulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const AppPulseDot({super.key, required this.color, this.size = 6});

  @override
  State<AppPulseDot> createState() => _AppPulseDotState();
}

class _AppPulseDotState extends State<AppPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: widget.size + 12,
          height: widget.size + 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0) * 0.5,
                child: Container(
                  width: widget.size + (t * 12),
                  height: widget.size + (t * 12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Scales a child in from slightly-smaller-than-normal up to full size with
/// an overshooting "spring" curve, once, as soon as it's built — used to add
/// a bouncy settle on top of a bottom sheet's (or any container's) entrance,
/// independent of whatever transition the surrounding modal/route provides.
class AppSpringIn extends StatefulWidget {
  final Widget child;
  final Alignment alignment;

  const AppSpringIn({super.key, required this.child, this.alignment = Alignment.bottomCenter});

  @override
  State<AppSpringIn> createState() => _AppSpringInState();
}

class _AppSpringInState extends State<AppSpringIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        alignment: widget.alignment,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class AppMilestoneCelebration extends StatefulWidget{
  final int trigger;
  final int particleCount;
  final IconData icon;
  final Color iconColor;
  
  const AppMilestoneCelebration({
    super.key,
    required this.trigger,
    this.particleCount = 24,
    this.icon = Icons.check,
    this.iconColor = AppColors.successGreen,
  });

  @override
  State<AppMilestoneCelebration> createState() => _AppMilestoneCelebrationState();
}

class _AppMilestoneCelebrationState extends State<AppMilestoneCelebration> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_ConfettiParticle> _particles = [];
  bool _visible = false;
  final _random = Random();

  static const _confettiColors = [
    Color(0xFF34D399),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
    Color.fromARGB(255, 207, 16, 16),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _visible = false);
      }
    });
    if (widget.trigger != 0) _play();
  }

  @override
  void didUpdateWidget(covariant AppMilestoneCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) _play();
  }

  void _play() {
    _particles = List.generate(widget.particleCount, (i) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 80 + _random.nextDouble() * 120;
      return _ConfettiParticle(
        dx: cos(angle) * distance,
        dy: sin(angle) * distance - 30,
        rotation: (_random.nextDouble() * 2 - 1) * 6,
        color: _confettiColors[i % _confettiColors.length],
        delay: _random.nextDouble() * 0.15,
      );
    });
    setState(() => _visible = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final iconT = Curves.easeOutBack.transform((_controller.value / 0.5).clamp(0.0, 1.0));
          return Stack(
            alignment: Alignment.center,
            children: [
              ..._particles.map((p) {
                final local = ((_controller.value - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
                final eased = Curves.easeOut.transform(local);
                final opacity = (1 - local).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(p.dx * eased, p.dy * eased),
                  child: Transform.rotate(
                    angle: p.rotation * eased,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(width: 8, height: 8, color: p.color),
                    ),
                  ),
                );
              }),
              Transform.scale(
                scale: iconT,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(color: widget.iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, size: 44, color: widget.iconColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  final double dx;
  final double dy;
  final double rotation;
  final Color color;
  final double delay;

  const _ConfettiParticle({
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.color,
    required this.delay,
  });
}

/// Wraps a child and shakes it horizontally (a decaying oscillation) every
/// time [trigger] changes value — pass an incrementing counter from an
/// Rx/Obx at the call site. Used to signal "this form has a problem" (e.g.
/// required fields left empty).
class AppShakeOnTrigger extends StatefulWidget {
  final Widget child;
  final int trigger;

  const AppShakeOnTrigger({super.key, required this.child, required this.trigger});

  @override
  State<AppShakeOnTrigger> createState() => _AppShakeOnTriggerState();
}

class _AppShakeOnTriggerState extends State<AppShakeOnTrigger> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AppShakeOnTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(offset: Offset(_offset.value, 0), child: child),
      child: widget.child,
    );
  }
}