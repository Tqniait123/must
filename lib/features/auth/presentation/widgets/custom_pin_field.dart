import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinField extends StatelessWidget {
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final int length;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool autoFocus;
  final bool readOnly;
  final TextEditingController? controller;

  const CustomPinField({
    super.key,
    required this.onChanged,
    this.validator,
    this.length = 6,
    this.obscureText = false,
    this.keyboardType = TextInputType.phone,
    this.autoFocus = false,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      pastedTextStyle: context.bodyMedium.s12,
      length: length,
      obscureText: obscureText,
      autoFocus: autoFocus,
      animationType: AnimationType.slide,
      showCursor: false,
      readOnly: readOnly, // Added readOnly property
      controller: controller, // Added controller property
      cursorWidth: 0,
      cursorColor: Colors.transparent,
      keyboardType: keyboardType,
      backgroundColor: Colors.transparent,
      enableActiveFill: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: onChanged,
      separatorBuilder: (context, index) => 10.gap,
      mainAxisAlignment: MainAxisAlignment.center,
      textStyle: context.bodyMedium.bold.s18.copyWith(color: AppColors.primary),
      dialogConfig: DialogConfig(
        dialogTitle: LocaleKeys.paste_code.tr(),
        dialogContent: LocaleKeys.paste_code_here.tr(),
        affirmativeText: LocaleKeys.paste.tr(),
        negativeText: LocaleKeys.cancel.tr(),
      ),
      pinTheme: PinTheme(
        fieldWidth: 40.r,
        fieldHeight: 40.r,

        shape: PinCodeFieldShape.underline,
        activeBorderWidth: 2,
        inactiveBorderWidth: 1,
        selectedBorderWidth: 2,
        borderRadius: BorderRadius.circular(0),
        inactiveFillColor: Colors.transparent,
        inactiveColor: AppColors.greyE4,
        activeFillColor: Colors.transparent,
        activeColor: AppColors.greyE4,
        selectedFillColor: Colors.transparent,
        selectedColor: AppColors.primary,
      ),
    ).paddingVertical(48);
  }
}
