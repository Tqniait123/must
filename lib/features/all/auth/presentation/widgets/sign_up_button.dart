import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({super.key, this.isLogin = true, this.onTap});
  final bool isLogin;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final String button =
        isLogin ? LocaleKeys.sign_up.tr() : LocaleKeys.login.tr();
    final String title =
        isLogin
            ? LocaleKeys.dont_have_an_account.tr()
            : LocaleKeys.already_have_an_account.tr();
    return Material(
      color:
          Colors
              .transparent, // Use transparent color if you don't want a background color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: context.bodyMedium.s14.regular),
          Text(button).clickable(
            onTap: () => onTap?.call(),
            padding: 8.0.edgeInsetsAll,
            style: context.titleLarge.s14.bold.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
