import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/context_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';

class BlurredBackgroundCircle extends StatelessWidget {
  const BlurredBackgroundCircle({
    super.key,
    this.top = -90,
    this.start = -140,
    this.color = AppColors.gradient,
  });

  final double top;
  final double start;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.directional(
          textDirection: context.textDirection,
          top: top,
          start: start,
          child: Container(
            width: 378,
            height: 378,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(378 / 2),
              color: color,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
