import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:shimmer/shimmer.dart';

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

class OfferItemWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final void Function()? onPressed;
  final Widget? trailing;

  const OfferItemWidget({super.key, required this.title, required this.iconPath, this.onPressed, this.trailing});

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xffFF512F), Color(0xffDD2476)], // 🔥 red → pink
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: iconPath.icon(color: Colors.white), // apply gradient
          ),
          18.gap,
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.redAccent,
              highlightColor: Colors.orangeAccent,
              child: Text(
                title,
                style: context.titleMedium.medium.s16.copyWith(
                  color: Colors.red, // fallback if shimmer not applied
                ),
              ),
            ),
          ),
          trailing ??
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: const Icon(
                  Icons.local_fire_department_rounded, // 🔥 more "offer" feel
                  size: 18,
                  color: Colors.white,
                ),
              ),
        ],
      ).withPressEffect(onTap: onPressed),
    );
  }
}
