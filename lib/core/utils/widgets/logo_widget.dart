import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/icons.dart';

enum LogoType { svg, png }

class LogoWidget extends StatelessWidget {
  final double? size;
  final LogoType type;
  final Color? color;

  const LogoWidget({
    super.key,
    this.size,
    this.type = LogoType.png,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(tag: 'logo', child: _buildLogo());
  }

  Widget _buildLogo() {
    switch (type) {
      case LogoType.svg:
        return SvgPicture.asset(
          AppIcons.splashLogo,
          width: size,
          colorFilter: color?.colorFilter,
        );
      case LogoType.png:
        return Image.asset(AppImages.wideLogo, width: size);
    }
  }
}
