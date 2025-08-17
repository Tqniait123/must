import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:libphonenumber_plugin/libphonenumber_plugin.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/sized_box.dart';
import 'package:must_invest/core/static/app_styles.dart';
import 'package:must_invest/core/static/country_list.dart';
import 'package:must_invest/core/static/country_model.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.hint,
    this.prefixIC,
    this.suffixIC,
    this.title,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.fieldName,
    this.shadow,
    this.onChanged,
    this.radius = 16,
    this.margin = 16,
    this.large = false,
    this.readonly = false,
    this.disabled = false,
    this.onTap,
    this.backgroundColor,
    this.hintColor,
    this.gender = 'male',
    this.isBordered,
    this.isPassword = false,
    this.waitTyping = false, // New bool parameter
    this.isRequired = false,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofillHints,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;
  final Widget? prefixIC;
  final Color? backgroundColor;
  final Color? hintColor;
  final Widget? suffixIC;
  final bool? isBordered;
  final String? title;
  final String? fieldName;
  final bool obscureText;
  final bool large;
  final bool readonly;
  final bool disabled;
  final double radius;
  final List<BoxShadow>? shadow;
  final double margin;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final String? Function(String? text)? validator;
  final void Function(String text)? onChanged;
  final bool isPassword;
  final TextAlign textAlign;
  final bool isRequired;
  final String gender;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool waitTyping; // New property to enable or disable debounce

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscure;
  Timer? _debounce; // Timer for debouncing

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
    if (widget.isPassword) {
      _isObscure = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce when widget is disposed
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    // Cancel the previous timer if it's still active
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    // Set up a new timer to delay the onChanged callback
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (widget.onChanged != null) {
        widget.onChanged!(value); // Call onChanged after debounce time
      }
    });
  }

  void _onChangedInstant(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value); // Directly call onChanged
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.grey, fontSize: 12.r, fontWeight: FontWeight.w400),
          ),
          8.ph,
        ],
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.margin),
          decoration: BoxDecoration(
            // color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
            // boxShadow:
            //     widget.shadow ??
            //     [
            //       const BoxShadow(
            //         color: Color(0x08000000),
            //         offset: Offset(0, 6),
            //         blurRadius: 12,
            //       ),
            //     ],
          ),
          // clipBehavior: Clip.hardEdge,
          child: TextFormField(
            onFieldSubmitted: widget.onSubmitted,
            inputFormatters: widget.keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : [],
            readOnly: widget.readonly,
            textAlign: widget.textAlign,
            autofillHints: widget.autofillHints,
            textAlignVertical: TextAlignVertical.center,
            style: AppStyles.medium12black.copyWith(fontSize: 15.r),
            showCursor: !widget.readonly,
            onTap: widget.onTap,

            validator: _compositeValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Theme.of(context).colorScheme.primary,
            autocorrect: true,
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            minLines: widget.large ? 2 : 1,
            maxLines: widget.large ? 2 : 1,
            obscureText: widget.isPassword ? _isObscure : widget.obscureText,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: (widget.isBordered ?? true) ? AppColors.primary : Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: (widget.isBordered ?? true) ? AppColors.borderColor : Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              filled: true,
              fillColor:
                  widget.backgroundColor ??
                  (widget.disabled ? const Color(0xff000000).withOpacity(0.2) : AppColors.white),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.5,
                  color: (widget.isBordered ?? true) ? Colors.transparent : AppColors.primary,
                ),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              // errorStyle: const TextStyle(
              //   height: 0.05,
              //   fontSize: 15,
              // ),
              errorMaxLines: 3,
              hintText: widget.hint,
              // labelText: widget.title,
              labelStyle: AppStyles.regular15greyC8,
              floatingLabelStyle: AppStyles.regular15greyC8.copyWith(color: AppColors.primary),
              hintMaxLines: widget.large ? 2 : 1,
              hintStyle: TextStyle(color: widget.hintColor ?? Colors.grey[300], fontSize: 14),
              prefixIcon:
                  widget.prefixIC != null
                      ? widget.large
                          ? Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Align(alignment: Alignment.topRight, child: widget.prefixIC),
                          ).flippedForLocale(context)
                          : Padding(padding: EdgeInsets.all(16.r), child: widget.prefixIC).flippedForLocale(context)
                      : null,
              prefixIconConstraints:
                  widget.large
                      ? const BoxConstraints(maxWidth: 24, minWidth: 24, maxHeight: double.infinity, minHeight: 24)
                      : null,
              suffixIcon:
                  widget.isPassword
                      ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                          child: SvgPicture.asset(
                            _isObscure ? AppIcons.eyeSlashIc : AppIcons.eyeIc,
                            height: 24.r,
                            width: 24.r,
                            colorFilter: const ColorFilter.mode(Color(0xffACB5BB), BlendMode.srcIn),
                          ),
                        ),
                      )
                      : widget.suffixIC != null
                      ? Padding(padding: const EdgeInsets.all(5), child: widget.suffixIC?.flippedForLocale(context))
                      : null,
              // suffixIconColor: AppColors.greyAB,
            ),
            // Call either debounced or instant onChanged based on the waitTyping flag
            onChanged: widget.waitTyping ? (value) => _onChangedDebounced(value) : (value) => _onChangedInstant(value),
          ),
        ),
      ],
    );
  }

  String? _compositeValidator(String? value) {
    // Check if the field is required and empty
    if (widget.isRequired && (value == null || value.isEmpty)) {
      // Fetch gender-specific string
      String genderKey = widget.gender == 'female' ? 'female' : 'male';

      return LocaleKeys.field_is_required.tr(
        namedArgs: {"fieldName": (widget.fieldName ?? widget.hint ?? widget.title ?? ''), genderKey: widget.gender},
        gender: genderKey,
      );
    }

    // If the field is of type number, ensure it's valid
    // if ((widget.keyboardType == TextInputType.phone) &&
    //     value != null &&
    //     !isValidPhone(value)) {
    //   return "يرجي ادخال رقم صحيح";
    // }

    // Call the custom validator if one is provided
    if (widget.validator != null) {
      final specificError = widget.validator!(value);
      if (specificError != null) {
        return specificError;
      }
    }

    if (widget.isPassword && value != null && value.length < 8) {
      return LocaleKeys.password_requirement.tr();
    }

    // If no errors, return null
    return null;
  }
}

// First, add this to your pubspec.yaml:
// dependencies:
//   intl_phone_number_input: ^0.7.4
