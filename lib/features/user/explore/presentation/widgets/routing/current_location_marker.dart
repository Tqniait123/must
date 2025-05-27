import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart'; // Make sure to import your colors

class CurrentLocationMarker extends StatelessWidget {
  final Animation<double> animation;
  final bool isNavigating;
  final String carName; // Add car name parameter

  const CurrentLocationMarker({
    super.key,
    required this.animation,
    required this.isNavigating,
    this.carName = "My Car", // Default value
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: isNavigating ? animation.value : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car icon container
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcons.carIc.icon(color: Colors.white, width: 16),
            ),
            const SizedBox(width: 8),
            // Car name text
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'My Car',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
