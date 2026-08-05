import 'package:flutter/material.dart';

/// Caps content width on large screens (tablet/desktop/web) and centers it,
/// so forms and content don't stretch edge-to-edge into unreadable rows.
/// On phone-sized screens, this has no visible effect.
class AppResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}