import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final bool isRounded; // Add isRounded parameter

  final double radius;

  const ShimmerContainer({
    super.key,
    this.width = double.infinity,
    this.height = 50.0,
    this.isRounded = true,
    this.radius = 16, // Set default to true
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0), // Light grey for a softer look
      highlightColor:
          const Color(0xFFBDBDBD), // Slightly darker grey for contrast
      child: ClipRRect(
        borderRadius: isRounded
            ? BorderRadius.circular(
                radius) // Apply rounding if isRounded is true
            : BorderRadius.zero, // No rounding if isRounded is false
        child: Container(
          height: height,
          width: width,
          color: const Color(0xFFE0E0E0), // Match the base color
        ),
      ),
    );
  }
}
