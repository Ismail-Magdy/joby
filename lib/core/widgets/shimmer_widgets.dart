import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable shimmer box used to build loading placeholders.
///
/// Use this as a building block inside shimmer layouts.
/// Must be placed inside a [Shimmer.fromColors] ancestor.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = .rectangle,
  });

  /// Creates a circular shimmer box (e.g. for avatars).
  const ShimmerBox.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = .circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: shape,
        borderRadius: shape == .rectangle ? .circular(borderRadius.r) : null,
      ),
    );
  }
}

/// Wraps its [child] in a shimmer animation with consistent colors.
///
/// Usage:
/// ```dart
/// ShimmerWrapper(
///   child: Column(
///     children: [
///       ShimmerBox(width: 200, height: 20),
///       ShimmerBox.circle(size: 80),
///     ],
///   ),
/// )
/// ```
class ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}
