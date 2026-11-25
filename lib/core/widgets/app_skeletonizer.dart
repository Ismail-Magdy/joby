import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shared [Skeletonizer] wrapper configured with Joby's shimmer effect colors
/// so all screen-level skeleton loading states share a consistent appearance.
class AppSkeletonizer extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const AppSkeletonizer({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        duration: const Duration(milliseconds: 1200),
      ),
      child: child,
    );
  }
}
