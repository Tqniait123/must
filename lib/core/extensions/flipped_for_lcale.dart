import 'package:flutter/material.dart';

extension LocaleBasedFlip on Widget {
  Widget flippedForLocale(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
      child: this,
    );
  }
}
