import 'package:flutter/material.dart';

extension LocaleBasedFlip on Widget {
  Widget flippedForLocale(BuildContext context, {bool reverse = false}) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    bool shouldFlip = reverse ? !isRtl : isRtl;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(shouldFlip ? -1.0 : 1.0, 1.0),
      child: this,
    );
  }
}
