import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AppStepperWidget extends StatelessWidget {
  const AppStepperWidget({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      animateFromLastPercent: true,
      isRTL: context.locale.toString() == 'ar',
      barRadius: const Radius.circular(1000),
      animation: true,
      lineHeight: 8.0,
      animationDuration: 700,
      addAutomaticKeepAlive: false,
      percent: percent,
      backgroundColor: AppColors.greyED,
      progressColor: AppColors.secondary,
    );
  }
}
