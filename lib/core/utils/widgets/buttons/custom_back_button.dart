import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onTap;
  const CustomBackButton({super.key, this.onTap, this.color = const Color(0xffEAEAF3)});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              log('CustomBackButton: Navigator.pop executed');
            } else {
              log('CustomBackButton: Cannot pop, maybe root screen?');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            width: 44.r,
            height: 44.r,
            decoration: ShapeDecoration(
              color: color ?? Colors.transparent,
              shape: RoundedRectangleBorder(
                // side: const BorderSide(width: 1, color: Color(0xFFF1F1F2)),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 3), spreadRadius: 0),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                height: 20.r,
                width: 20.r,
                AppIcons.arrowBackIc,
                colorFilter: ColorFilter.mode(
                  color == AppColors.primary.withValues(alpha: 0.4)
                      ? Colors.black
                      : AppColors.primary.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ).flippedForLocale(context, reverse: true),

            //  Center(
            //   child: Icon(
            //     Icons.arrow_back_ios_new_rounded,
            //     color:
            //         color == AppColors.primary.withValues(alpha: 0.4)
            //             ? Colors.black
            //             : AppColors.primary.withValues(alpha: 0.4),
            //     size: 20,
            //   ),
            // ),
          ),
        ),
      ),
    ).withPressEffect();
  }
}
