import 'package:flutter/material.dart';

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var w = size.width; // Get the total width of the widget
    var h = size.height; // Get the total height of the widget
    Path path = Path(); // Create a new path

    // Start from the bottom-left corner
    path.lineTo(0, h * 0.3);

    // First curve from left bottom corner upwards
    path.quadraticBezierTo(w * 0.15, 0, w * 0.3, 0);

    // Smooth transition before the center arc
    path.quadraticBezierTo(w * 0.38, 0, w * 0.38, 10);

    // Deeper arc in the center for Floating Action Button
    path.arcToPoint(Offset(w * 0.62, 0),
        clockwise: false, radius: const Radius.circular(10));

    // Smooth transition back to the bar level
    path.quadraticBezierTo(w * 0.62, 0, w * 0.7, 0);

    // Final curve to the right bottom corner
    path.quadraticBezierTo(w * 0.85, 0, w, h * 0.3);

    // Close the path by connecting back to the starting point
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      true; // Always reclip when changes occur
}
