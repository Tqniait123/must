import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    this.amountTextSize,
    this.fontColor,
  });

  final String amount;
  final double? amountTextSize;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          context.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amount,
            style: context.bodyMedium.bold.s12.copyWith(
              fontSize: amountTextSize,
              color: fontColor,
            ),
          ),
          4.gap,
          Text(
            LocaleKeys.EGP.tr(),
            style: context.bodyMedium.bold.s12.copyWith(
              color: fontColor ?? AppColors.grey60,
            ),
          ),
        ],
      ),
    );
  }
}
