import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/widgets/app_shimmer.dart';

/// Skeleton for one Update / Notice / Complaint card.
class UpdateCardSkeleton extends StatelessWidget {
  const UpdateCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppShimmerBox(width: 80, height: 20, radius: AppDimens.radiusFull),
              Spacer(),
              AppShimmerBox(width: 50, height: 14),
            ],
          ),
          SizedBox(height: 12),
          AppShimmerBox(height: 18, width: 180),
          SizedBox(height: 8),
          AppShimmerBox(height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for one Staff card.
class StaffTileSkeleton extends StatelessWidget {
  const StaffTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerBox(width: 48, height: 48, radius: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(height: 16, width: 120),
                SizedBox(height: 6),
                AppShimmerBox(height: 12, width: 90),
                SizedBox(height: 8),
                Row(
                  children: [
                    AppShimmerBox(width: 60, height: 20, radius: AppDimens.radiusSm),
                    SizedBox(width: 8),
                    AppShimmerBox(width: 60, height: 20, radius: AppDimens.radiusSm),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for one Building card.
class BuildingTileSkeleton extends StatelessWidget {
  const BuildingTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
      ),
      child: const Row(
        children: [
          AppShimmerBox(width: 48, height: 48, radius: 14),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(height: 18, width: 100),
                SizedBox(height: 6),
                AppShimmerBox(height: 12, width: 130),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Repeats a single skeleton card [count] times with spacing.
class AppSkeletonList extends StatelessWidget {
  final Widget Function() itemBuilder;
  final int count;
  final EdgeInsetsGeometry padding;

  const AppSkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 5,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmerWrapper(
      child: ListView.separated(
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => itemBuilder(),
      ),
    );
  }
}