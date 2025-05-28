import 'package:flutter/material.dart';

//Copy this CustomPainter code to the Bottom of the File
class CurveCustomPainter extends CustomPainter {
  final bool isSelected;
  CurveCustomPainter({this.isSelected = false});
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.3571429);
    path_0.cubicTo(
      0,
      size.height * 0.1887839,
      0,
      size.height * 0.1046046,
      size.width * 0.04012233,
      size.height * 0.05230232,
    );
    path_0.cubicTo(
      size.width * 0.08024466,
      0,
      size.width * 0.1448205,
      0,
      size.width * 0.2739726,
      0,
    );
    path_0.lineTo(size.width * 0.7260274, 0);
    path_0.cubicTo(
      size.width * 0.8551795,
      0,
      size.width * 0.9197548,
      0,
      size.width * 0.9598781,
      size.height * 0.05230232,
    );
    path_0.cubicTo(
      size.width,
      size.height * 0.1046046,
      size.width,
      size.height * 0.1887839,
      size.width,
      size.height * 0.3571429,
    );
    path_0.lineTo(size.width, size.height * 0.6111464);
    path_0.cubicTo(
      size.width,
      size.height * 0.7362429,
      size.width,
      size.height * 0.7987911,
      size.width * 0.9709329,
      size.height * 0.8472589,
    );
    path_0.cubicTo(
      size.width * 0.9418644,
      size.height * 0.8957250,
      size.width * 0.8983384,
      size.height * 0.9098304,
      size.width * 0.8112877,
      size.height * 0.9380429,
    );
    path_0.cubicTo(
      size.width * 0.7136274,
      size.height * 0.9696946,
      size.width * 0.5952479,
      size.height,
      size.width * 0.5000000,
      size.height,
    );
    path_0.cubicTo(
      size.width * 0.4047521,
      size.height,
      size.width * 0.2863726,
      size.height * 0.9696946,
      size.width * 0.1887123,
      size.height * 0.9380429,
    );
    path_0.cubicTo(
      size.width * 0.1016614,
      size.height * 0.9098304,
      size.width * 0.05813562,
      size.height * 0.8957250,
      size.width * 0.02906781,
      size.height * 0.8472589,
    );
    path_0.cubicTo(
      0,
      size.height * 0.7987911,
      0,
      size.height * 0.7362429,
      0,
      size.height * 0.6111464,
    );
    path_0.lineTo(0, size.height * 0.3571429);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color =
        isSelected ? Color(0xff2B3085).withOpacity(1.0) : Colors.transparent;
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CurveCustomPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}

class CurveCustomClipper extends CustomClipper<Path> {
  final bool isReversed;

  CurveCustomClipper({this.isReversed = false});

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Original path (the "dip" is at the bottom)
    path.moveTo(0, size.height * 0.3571429);
    path.cubicTo(
      0,
      size.height * 0.1887839,
      0,
      size.height * 0.1046046,
      size.width * 0.04012233,
      size.height * 0.05230232,
    );
    path.cubicTo(
      size.width * 0.08024466,
      0,
      size.width * 0.1448205,
      0,
      size.width * 0.2739726,
      0,
    );
    path.lineTo(size.width * 0.7260274, 0);
    path.cubicTo(
      size.width * 0.8551795,
      0,
      size.width * 0.9197548,
      0,
      size.width * 0.9598781,
      size.height * 0.05230232,
    );
    path.cubicTo(
      size.width,
      size.height * 0.1046046,
      size.width,
      size.height * 0.1887839,
      size.width,
      size.height * 0.3571429,
    );
    path.lineTo(size.width, size.height * 0.6111464);
    path.cubicTo(
      size.width,
      size.height * 0.7362429,
      size.width,
      size.height * 0.7987911,
      size.width * 0.9709329,
      size.height * 0.8472589,
    );
    path.cubicTo(
      size.width * 0.9418644,
      size.height * 0.8957250,
      size.width * 0.8983384,
      size.height * 0.9098304,
      size.width * 0.8112877,
      size.height * 0.9380429,
    );
    path.cubicTo(
      size.width * 0.7136274,
      size.height * 0.9696946,
      size.width * 0.5952479,
      size.height,
      size.width * 0.5000000,
      size.height,
    );
    path.cubicTo(
      size.width * 0.4047521,
      size.height,
      size.width * 0.2863726,
      size.height * 0.9696946,
      size.width * 0.1887123,
      size.height * 0.9380429,
    );
    path.cubicTo(
      size.width * 0.1016614,
      size.height * 0.9098304,
      size.width * 0.05813562,
      size.height * 0.8957250,
      size.width * 0.02906781,
      size.height * 0.8472589,
    );
    path.cubicTo(
      0,
      size.height * 0.7987911,
      0,
      size.height * 0.7362429,
      0,
      size.height * 0.6111464,
    );
    path.lineTo(0, size.height * 0.3571429);
    path.close();

    // 🔁 Flip the path vertically if reversed
    if (isReversed) {
      final Matrix4 matrix4 =
          Matrix4.identity()
            ..translate(0.0, size.height)
            ..scale(1.0, -1.0); // Flip vertically
      return path.transform(matrix4.storage);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
