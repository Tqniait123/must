import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

extension IconString on String {
  SvgPicture icon({
    double height = 24,
    double width = 24,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return SvgPicture.asset(
      this,
      height: height != 0 ? height.r : null,
      width: width != 0 ? width.r : null,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

extension SvgString on String {
  SvgPicture svg({
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return SvgPicture.asset(
      this,
      height: height,
      width: width,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
