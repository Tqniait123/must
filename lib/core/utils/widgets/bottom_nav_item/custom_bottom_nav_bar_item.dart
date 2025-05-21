import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:must_invest/core/static/app_styles.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';

class CustomBottomNavigationBarItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final String iconFilledPath;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomBottomNavigationBarItem({
    super.key,
    required this.title,
    required this.iconPath,
    required this.isSelected,
    required this.iconFilledPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        // border: Border(
        //   top: BorderSide(
        //     color: isSelected ? AppColors.primary : Colors.transparent,
        //     width: 2.0,
        //   ),
        // ),
      ),
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isSelected ? iconFilledPath : iconPath,
            colorFilter:
                !isSelected
                    ? const ColorFilter.mode(AppColors.grey60, BlendMode.srcIn)
                    : const ColorFilter.mode(
                      AppColors.secondary,
                      BlendMode.srcIn,
                    ),
            height: 27.h,
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: AppStyles.medium12black.copyWith(
                color: isSelected ? AppColors.secondary : AppColors.grey78,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ).withPressEffect(onTap: onTap, onLongPress: onTap);
  }
}
