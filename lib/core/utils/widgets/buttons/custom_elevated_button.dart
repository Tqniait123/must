import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/sized_box.dart';
import 'package:must_invest/core/extensions/txt_theme.dart';
import 'package:must_invest/core/functions/unfocus.dart';
import 'package:must_invest/core/theme/colors.dart';

enum IconPosition { start, end }

enum IconType { leading, center, trailing }

class CustomElevatedButton extends StatefulWidget {
  final String title;
  final bool isFilled;
  final bool loading;
  final String? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;
  final void Function()? onPressed;
  final double? height;
  final bool reverse;
  final bool isDisabled;
  final bool isBordered;
  final bool withShadow;
  final bool gradient;
  final bool withFlipIcon;
  final String? heroTag;
  final double padding;

  final BorderRadiusGeometry? borderRadius;
  final IconPosition iconPosition;
  final IconType iconType;

  const CustomElevatedButton({
    super.key,
    required this.title,
    this.isFilled = true,
    required this.onPressed,
    this.height = 60,
    this.padding = 24,
    this.icon,
    this.iconColor = AppColors.white,
    this.textColor = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.loading = false,
    this.reverse = false,
    this.isDisabled = false,
    this.withShadow = false,
    this.isBordered = false,
    this.gradient = false,
    this.withFlipIcon = true,
    this.heroTag,
    this.borderRadius,
    this.iconPosition = IconPosition.start,
    this.iconType = IconType.leading,
  });

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag ?? 'button',
      child: GestureDetector(
        onTapDown: (_) {
          dismissKeyboard();
          if (!_isPressed) {
            _controller.forward();
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          _controller.reverse();
          setState(() => _isPressed = false);
          _handlePress();
        },
        onTapCancel: () {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _isPressed ? 0.7 : (widget.loading ? 0.5 : 1.0),
                child: Container(
                  width: double.infinity,
                  height: widget.height?.h ?? 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border:
                        widget.isBordered
                            ? Border.all(
                              color:
                                  widget.isDisabled
                                      ? AppColors.disableColor
                                      : AppColors.greyED,
                              width: 1.0,
                            )
                            : null,

                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(15),

                    color:
                    
                        widget.isDisabled
                            ? AppColors.disableColor
                            : (widget.isFilled
                                ? (widget.backgroundColor ?? AppColors.primary)
                                : AppColors.whiteEA),
                    boxShadow:
                        widget.withShadow
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ]
                            : [],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: widget.padding),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child:
                        widget.loading
                            ? SpinKitWave(
                              key: const ValueKey('loading'),
                              color: widget.iconColor,
                              size: 20,
                              type: SpinKitWaveType.start,
                            )
                            : Row(
                              key: const ValueKey('content'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null &&
                                    (widget.iconType == IconType.leading ||
                                        widget.iconType ==
                                            IconType.center)) ...[
                                  SvgPicture.asset(
                                    widget.icon!,
                                    colorFilter:
                                        widget.iconColor != null
                                            ? ColorFilter.mode(
                                              widget.iconColor!,
                                              BlendMode.srcIn,
                                            )
                                            : null,
                                  ),
                                  7.pw,
                                ],
                                Expanded(
                                  child: AutoSizeText(
                                    widget.title.tr(),
                                    style: context.theme.textTheme.bodyLarge!
                                        .copyWith(
                                          color:
                                              widget.textColor ??
                                              (widget.isFilled
                                                  ? AppColors.white
                                                  : Color(0xff2D2D2D)),
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (widget.icon != null &&
                                    (widget.iconType == IconType.trailing ||
                                        widget.iconType ==
                                            IconType.center)) ...[
                                  7.pw,
                                  if (widget.withFlipIcon) ...[
                                    SvgPicture.asset(
                                      widget.icon!,
                                      colorFilter:
                                          widget.iconColor != null
                                              ? ColorFilter.mode(
                                                widget.iconColor!,
                                                BlendMode.srcIn,
                                              )
                                              : null,
                                    ).flippedForLocale(context),
                                  ] else ...[
                                    SvgPicture.asset(
                                      widget.icon!,
                                      colorFilter:
                                          widget.iconColor != null
                                              ? ColorFilter.mode(
                                                widget.iconColor!,
                                                BlendMode.srcIn,
                                              )
                                              : null,
                                    ),
                                  ],
                                ],
                              ],
                            ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
