import 'package:flutter/material.dart';

class RotatingGradientIndicator extends StatefulWidget {
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;
  final Duration duration;

  const RotatingGradientIndicator({
    super.key,
    required this.radius,
    required this.gradientColors,
    required this.strokeWidth,
    this.duration = const Duration(seconds: 1),
  });

  @override
  _RotatingGradientIndicatorState createState() =>
      _RotatingGradientIndicatorState();
}

class _RotatingGradientIndicatorState extends State<RotatingGradientIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
      child: GradientCircularProgressIndicator(
        radius: widget.radius,
        gradientColors: widget.gradientColors,
        strokeWidth: widget.strokeWidth,
      ),
    );
  }
}

class GradientCircularProgressIndicator extends StatelessWidget {
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  const GradientCircularProgressIndicator({
    super.key,
    required this.radius,
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _GradientCircularProgressPainter(
          gradientColors: gradientColors,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double strokeWidth;

  _GradientCircularProgressPainter({
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: 0.0,
      endAngle: 2 * 3.141592653589793,
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final radius = center - strokeWidth / 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      0.0,
      2 * 3.141592653589793,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
