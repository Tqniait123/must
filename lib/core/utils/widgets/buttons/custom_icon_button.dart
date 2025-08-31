import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:must_invest/core/theme/colors.dart';

class CustomIconButton extends StatefulWidget {
  final Color color;
  final String iconAsset;
  final Color? iconColor;
  final Color? borderColor;
  final bool isBordered;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final BoxShadow? boxShadow;
  final double radius;

  const CustomIconButton({
    super.key,
    required this.color,
    required this.iconAsset,
    required this.onPressed,
    this.iconColor,
    this.borderColor,
    this.isBordered = false,
    this.width = 44.0,
    this.height = 44.0,
    this.radius = 10.0,
    this.boxShadow,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double _scale = 1.0;
  double _opacity = 1.0;

  void _onTapDown() {
    setState(() {
      _scale = 0.92;
      _opacity = 0.6;
    });
  }

  void _onTapUp() {
    setState(() {
      _scale = 1.0;
      _opacity = 1.0;
    });
  }

  void _onTapCancel() {
    _onTapUp();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPress: widget.onPressed,
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _opacity,
          child: Container(
            width: widget.width.w,
            height: widget.height.h,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: widget.boxShadow != null ? [widget.boxShadow!] : null,
              border: widget.isBordered ? Border.all(color: widget.borderColor ?? AppColors.greyED, width: 2.0) : null,
            ),
            child: Center(
              child: SvgPicture.asset(
                height: 20.r,
                width: 20.r,
                widget.iconAsset,
                colorFilter: widget.iconColor != null ? ColorFilter.mode(widget.iconColor!, BlendMode.srcIn) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
