import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';

/// Centered loading spinner, used while async data (repository calls) is
/// being fetched — e.g. Registration Status waiting on getCurrentSociety().
class AppLoading extends StatelessWidget {
  final Color color;
  const AppLoading({super.key, this.color = AppColors.primaryDark});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: color));
  }
}