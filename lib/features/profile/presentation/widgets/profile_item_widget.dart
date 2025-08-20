import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';

class ProfileItemWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final void Function()? onPressed;
  final Widget? trailing;
  final Color? color; // New parameter for custom color

  const ProfileItemWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.onPressed,
    this.trailing,
    this.color, // Optional color parameter
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.primary; // Use custom color or default to primary

    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 38),
      child: Row(
        children: [
          iconPath.icon(color: itemColor),
          18.gap,
          Expanded(
            child: Text(
              title,
              style: context.titleMedium.regular.s14.copyWith(
                color: itemColor, // Apply color to text as well
              ),
            ),
          ),
          trailing ?? // arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: itemColor, // Apply color to arrow
              ),
        ],
      ),
    ).withPressEffect(onTap: onPressed);
  }
}
