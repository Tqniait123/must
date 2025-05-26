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
  const ProfileItemWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.onPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 38),
      child: Row(
        children: [
          iconPath.icon(color: AppColors.primary),
          18.gap,
          Expanded(
            child: Text(
              title,
              style: context.titleMedium.regular.s14.copyWith(),
            ),
          ),
          trailing ?? // arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
        ],
      ),
    ).withPressEffect(onTap: onPressed);
  }
}
