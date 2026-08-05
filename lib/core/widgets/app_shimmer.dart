import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';

/// Wraps any skeleton layout in the shimmer sweep animation.
class AppShimmerWrapper extends StatelessWidget {
  final Widget child;

  const AppShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Basic gray rounded-rect placeholder block.
class AppShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const AppShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppDimens.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // Shimmer overrides this
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}