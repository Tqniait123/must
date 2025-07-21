import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/sized_box.dart';
import 'package:must_invest/core/static/app_styles.dart';
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

class CustomPhoneFormField extends StatefulWidget {
  const CustomPhoneFormField({
    super.key,
    required this.controller,
    required this.selectedCode,
    this.onChangedCountryCode,
    this.onChanged,
    this.validator,
    this.title,
    this.hint,
    this.fieldName,
    this.shadow,
    this.radius = 16,
    this.margin = 16,
    this.readonly = false,
    this.disabled = false,
    this.onTap,
    this.backgroundColor,
    this.hintColor,
    this.gender = 'male',
    this.isBordered,
    this.waitTyping = false,
    this.isRequired = false,
    this.textAlign = TextAlign.start,
    this.includeCountryCodeInValue = false,
  });

  final TextEditingController controller;
  final String selectedCode;
  final void Function(String code)? onChangedCountryCode;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? title;
  final String? hint;
  final String? fieldName;
  final List<BoxShadow>? shadow;
  final double radius;
  final double margin;
  final bool readonly;
  final bool disabled;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? hintColor;
  final String gender;
  final bool? isBordered;
  final bool waitTyping;
  final bool isRequired;
  final TextAlign textAlign;
  final bool includeCountryCodeInValue;

  @override
  State<CustomPhoneFormField> createState() => _CustomPhoneFormFieldState();
}

class _CustomPhoneFormFieldState extends State<CustomPhoneFormField> {
  Timer? _debounce;
  String _currentCountryCode = '';

  @override
  void initState() {
    super.initState();
    _currentCountryCode = widget.selectedCode;
    if (widget.includeCountryCodeInValue) {
      _updateControllerWithCountryCode();
    }
  }

  @override
  void didUpdateWidget(CustomPhoneFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCode != widget.selectedCode) {
      setState(() {
        _currentCountryCode = widget.selectedCode;
      });
      if (widget.includeCountryCodeInValue) {
        _updateControllerWithCountryCode();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _updateControllerWithCountryCode() {
    final text = widget.controller.text;
    if (text.startsWith(_currentCountryCode)) return;

    String cleanedText = text;
    for (var code in _countryCodes.map((c) => c['code']!)) {
      if (text.startsWith(code)) {
        cleanedText = text.substring(code.length);
        break;
      }
    }

    widget.controller.text = '$_currentCountryCode$cleanedText';
    widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
  }

  void _onChangedDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (widget.onChanged != null) {
        widget.onChanged!(widget.includeCountryCodeInValue ? value : _currentCountryCode + value);
      }
    });
  }

  void _onChangedInstant(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.includeCountryCodeInValue ? value : _currentCountryCode + value);
    }
  }

  void _handleCountryCodeChange(String? newCode) {
    if (newCode == null || newCode == _currentCountryCode) return;

    setState(() => _currentCountryCode = newCode);

    widget.onChangedCountryCode?.call(newCode);

    if (widget.includeCountryCodeInValue) {
      _updateControllerWithCountryCode();
    }
  }

  String _getDisplayValue(String value) {
    if (!widget.includeCountryCodeInValue) return value;

    if (value.startsWith(_currentCountryCode)) {
      return value.substring(_currentCountryCode.length);
    }

    for (var code in _countryCodes.map((c) => c['code']!)) {
      if (code != _currentCountryCode && value.startsWith(code)) {
        return value.substring(code.length);
      }
    }

    return value;
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
            ).textTheme.labelMedium?.copyWith(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.margin),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(widget.radius))),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            readOnly: widget.readonly,
            textAlign: widget.textAlign,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
            showCursor: !widget.readonly,
            onTap: widget.onTap,
            validator: _compositeValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Theme.of(context).colorScheme.primary,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: (widget.isBordered ?? true) ? Colors.blue : Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: (widget.isBordered ?? true) ? Colors.grey : Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              filled: true,
              fillColor:
                  widget.backgroundColor ?? (widget.disabled ? const Color(0xff000000).withOpacity(0.2) : Colors.white),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.5,
                  color: (widget.isBordered ?? true) ? Colors.transparent : Colors.blue,
                ),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
              errorMaxLines: 3,
              hintText: widget.hint,
              labelStyle: const TextStyle(fontSize: 15, color: Color(0xFFC8C8C8)),
              floatingLabelStyle: const TextStyle(fontSize: 15, color: Colors.blue),
              hintStyle: TextStyle(color: widget.hintColor ?? Colors.grey[300], fontSize: 14),
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: _currentCountryCode,
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey[700]),
                      items:
                          _countryCodes.map((code) {
                            return DropdownMenuItem(
                              value: code['code'],
                              child: Row(
                                children: [
                                  Text(code['flag'] ?? '', style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    code['code']!,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: widget.disabled ? null : _handleCountryCodeChange,
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            onChanged: (value) {
              final displayValue = _getDisplayValue(value);
              if (widget.waitTyping) {
                _onChangedDebounced(displayValue);
              } else {
                _onChangedInstant(displayValue);
              }
            },
          ),
        ),
      ],
    );
  }

  String? _compositeValidator(String? value) {
    // if (widget.isRequired && (value == null || value.isEmpty)) {
    //   return 'This field is required';
    // }

    final fullNumber = widget.includeCountryCodeInValue ? value : _currentCountryCode + (value ?? '');

    if (widget.validator != null) {
      return widget.validator!(fullNumber);
    }

    return null;
  }
}

const List<Map<String, String>> _countryCodes = [
  {'code': '+93', 'name': 'Afghanistan', 'flag': '🇦🇫'},
  {'code': '+355', 'name': 'Albania', 'flag': '🇦🇱'},
  {'code': '+213', 'name': 'Algeria', 'flag': '🇩🇿'},
  {'code': '+1-684', 'name': 'American Samoa', 'flag': '🇦🇸'},
  {'code': '+376', 'name': 'Andorra', 'flag': '🇦🇩'},
  {'code': '+244', 'name': 'Angola', 'flag': '🇦🇴'},
  {'code': '+1-264', 'name': 'Anguilla', 'flag': '🇦🇮'},
  {'code': '+672', 'name': 'Antarctica', 'flag': '🇦🇶'},
  {'code': '+1-268', 'name': 'Antigua and Barbuda', 'flag': '🇦🇬'},
  {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
  {'code': '+374', 'name': 'Armenia', 'flag': '🇦🇲'},
  {'code': '+297', 'name': 'Aruba', 'flag': '🇦🇼'},
  {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
  {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
  {'code': '+994', 'name': 'Azerbaijan', 'flag': '🇦🇿'},
  {'code': '+1-242', 'name': 'Bahamas', 'flag': '🇧🇸'},
  {'code': '+973', 'name': 'Bahrain', 'flag': '🇧🇭'},
  {'code': '+880', 'name': 'Bangladesh', 'flag': '🇧🇩'},
  {'code': '+1-246', 'name': 'Barbados', 'flag': '🇧🇧'},
  {'code': '+375', 'name': 'Belarus', 'flag': '🇧🇾'},
  {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
  {'code': '+501', 'name': 'Belize', 'flag': '🇧🇿'},
  {'code': '+229', 'name': 'Benin', 'flag': '🇧🇯'},
  {'code': '+1-441', 'name': 'Bermuda', 'flag': '🇧🇲'},
  {'code': '+975', 'name': 'Bhutan', 'flag': '🇧🇹'},
  {'code': '+591', 'name': 'Bolivia', 'flag': '🇧🇴'},
  {'code': '+387', 'name': 'Bosnia and Herzegovina', 'flag': '🇧🇦'},
  {'code': '+267', 'name': 'Botswana', 'flag': '🇧🇼'},
  {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
  {'code': '+246', 'name': 'British Indian Ocean Territory', 'flag': '🇮🇴'},
  {'code': '+1-284', 'name': 'British Virgin Islands', 'flag': '🇻🇬'},
  {'code': '+673', 'name': 'Brunei', 'flag': '🇧🇳'},
  {'code': '+359', 'name': 'Bulgaria', 'flag': '🇧🇬'},
  {'code': '+226', 'name': 'Burkina Faso', 'flag': '🇧🇫'},
  {'code': '+257', 'name': 'Burundi', 'flag': '🇧🇮'},
  {'code': '+855', 'name': 'Cambodia', 'flag': '🇰🇭'},
  {'code': '+237', 'name': 'Cameroon', 'flag': '🇨🇲'},
  {'code': '+1', 'name': 'Canada', 'flag': '🇨🇦'},
  {'code': '+238', 'name': 'Cape Verde', 'flag': '🇨🇻'},
  {'code': '+1-345', 'name': 'Cayman Islands', 'flag': '🇰🇾'},
  {'code': '+236', 'name': 'Central African Republic', 'flag': '🇨🇫'},
  {'code': '+235', 'name': 'Chad', 'flag': '🇹🇩'},
  {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
  {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
  {'code': '+61', 'name': 'Christmas Island', 'flag': '🇨🇽'},
  {'code': '+61', 'name': 'Cocos Islands', 'flag': '🇨🇨'},
  {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
  {'code': '+269', 'name': 'Comoros', 'flag': '🇰🇲'},
  {'code': '+682', 'name': 'Cook Islands', 'flag': '🇨🇰'},
  {'code': '+506', 'name': 'Costa Rica', 'flag': '🇨🇷'},
  {'code': '+385', 'name': 'Croatia', 'flag': '🇭🇷'},
  {'code': '+53', 'name': 'Cuba', 'flag': '🇨🇺'},
  {'code': '+599', 'name': 'Curacao', 'flag': '🇨🇼'},
  {'code': '+357', 'name': 'Cyprus', 'flag': '🇨🇾'},
  {'code': '+420', 'name': 'Czech Republic', 'flag': '🇨🇿'},
  {'code': '+243', 'name': 'Democratic Republic of the Congo', 'flag': '🇨🇩'},
  {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
  {'code': '+253', 'name': 'Djibouti', 'flag': '🇩🇯'},
  {'code': '+1-767', 'name': 'Dominica', 'flag': '🇩🇲'},
  {'code': '+1-809', 'name': 'Dominican Republic', 'flag': '🇩🇴'},
  {'code': '+670', 'name': 'East Timor', 'flag': '🇹🇱'},
  {'code': '+593', 'name': 'Ecuador', 'flag': '🇪🇨'},
  {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
  {'code': '+503', 'name': 'El Salvador', 'flag': '🇸🇻'},
  {'code': '+240', 'name': 'Equatorial Guinea', 'flag': '🇬🇶'},
  {'code': '+291', 'name': 'Eritrea', 'flag': '🇪🇷'},
  {'code': '+372', 'name': 'Estonia', 'flag': '🇪🇪'},
  {'code': '+251', 'name': 'Ethiopia', 'flag': '🇪🇹'},
  {'code': '+500', 'name': 'Falkland Islands', 'flag': '🇫🇰'},
  {'code': '+298', 'name': 'Faroe Islands', 'flag': '🇫🇴'},
  {'code': '+679', 'name': 'Fiji', 'flag': '🇫🇯'},
  {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
  {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
  {'code': '+689', 'name': 'French Polynesia', 'flag': '🇵🇫'},
  {'code': '+241', 'name': 'Gabon', 'flag': '🇬🇦'},
  {'code': '+220', 'name': 'Gambia', 'flag': '🇬🇲'},
  {'code': '+995', 'name': 'Georgia', 'flag': '🇬🇪'},
  {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
  {'code': '+233', 'name': 'Ghana', 'flag': '🇬🇭'},
  {'code': '+350', 'name': 'Gibraltar', 'flag': '🇬🇮'},
  {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
  {'code': '+299', 'name': 'Greenland', 'flag': '🇬🇱'},
  {'code': '+1-473', 'name': 'Grenada', 'flag': '🇬🇩'},
  {'code': '+1-671', 'name': 'Guam', 'flag': '🇬🇺'},
  {'code': '+502', 'name': 'Guatemala', 'flag': '🇬🇹'},
  {'code': '+44-1481', 'name': 'Guernsey', 'flag': '🇬🇬'},
  {'code': '+224', 'name': 'Guinea', 'flag': '🇬🇳'},
  {'code': '+245', 'name': 'Guinea-Bissau', 'flag': '🇬🇼'},
  {'code': '+592', 'name': 'Guyana', 'flag': '🇬🇾'},
  {'code': '+509', 'name': 'Haiti', 'flag': '🇭🇹'},
  {'code': '+504', 'name': 'Honduras', 'flag': '🇭🇳'},
  {'code': '+852', 'name': 'Hong Kong', 'flag': '🇭🇰'},
  {'code': '+36', 'name': 'Hungary', 'flag': '🇭🇺'},
  {'code': '+354', 'name': 'Iceland', 'flag': '🇮🇸'},
  {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
  {'code': '+62', 'name': 'Indonesia', 'flag': '🇮🇩'},
  {'code': '+98', 'name': 'Iran', 'flag': '🇮🇷'},
  {'code': '+964', 'name': 'Iraq', 'flag': '🇮🇶'},
  {'code': '+353', 'name': 'Ireland', 'flag': '🇮🇪'},
  {'code': '+44-1624', 'name': 'Isle of Man', 'flag': '🇮🇲'},
  {'code': '+972', 'name': 'Israel', 'flag': '🇮🇱'},
  {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
  {'code': '+225', 'name': 'Ivory Coast', 'flag': '🇨🇮'},
  {'code': '+1-876', 'name': 'Jamaica', 'flag': '🇯🇲'},
  {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
  {'code': '+44-1534', 'name': 'Jersey', 'flag': '🇯🇪'},
  {'code': '+962', 'name': 'Jordan', 'flag': '🇯🇴'},
  {'code': '+7', 'name': 'Kazakhstan', 'flag': '🇰🇿'},
  {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
  {'code': '+686', 'name': 'Kiribati', 'flag': '🇰🇮'},
  {'code': '+383', 'name': 'Kosovo', 'flag': '🇽🇰'},
  {'code': '+965', 'name': 'Kuwait', 'flag': '🇰🇼'},
  {'code': '+996', 'name': 'Kyrgyzstan', 'flag': '🇰🇬'},
  {'code': '+856', 'name': 'Laos', 'flag': '🇱🇦'},
  {'code': '+371', 'name': 'Latvia', 'flag': '🇱🇻'},
  {'code': '+961', 'name': 'Lebanon', 'flag': '🇱🇧'},
  {'code': '+266', 'name': 'Lesotho', 'flag': '🇱🇸'},
  {'code': '+231', 'name': 'Liberia', 'flag': '🇱🇷'},
  {'code': '+218', 'name': 'Libya', 'flag': '🇱🇾'},
  {'code': '+423', 'name': 'Liechtenstein', 'flag': '🇱🇮'},
  {'code': '+370', 'name': 'Lithuania', 'flag': '🇱🇹'},
  {'code': '+352', 'name': 'Luxembourg', 'flag': '🇱🇺'},
  {'code': '+853', 'name': 'Macau', 'flag': '🇲🇴'},
  {'code': '+389', 'name': 'Macedonia', 'flag': '🇲🇰'},
  {'code': '+261', 'name': 'Madagascar', 'flag': '🇲🇬'},
  {'code': '+265', 'name': 'Malawi', 'flag': '🇲🇼'},
  {'code': '+60', 'name': 'Malaysia', 'flag': '🇲🇾'},
  {'code': '+960', 'name': 'Maldives', 'flag': '🇲🇻'},
  {'code': '+223', 'name': 'Mali', 'flag': '🇲🇱'},
  {'code': '+356', 'name': 'Malta', 'flag': '🇲🇹'},
  {'code': '+692', 'name': 'Marshall Islands', 'flag': '🇲🇭'},
  {'code': '+222', 'name': 'Mauritania', 'flag': '🇲🇷'},
  {'code': '+230', 'name': 'Mauritius', 'flag': '🇲🇺'},
  {'code': '+262', 'name': 'Mayotte', 'flag': '🇾🇹'},
  {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
  {'code': '+691', 'name': 'Micronesia', 'flag': '🇫🇲'},
  {'code': '+373', 'name': 'Moldova', 'flag': '🇲🇩'},
  {'code': '+377', 'name': 'Monaco', 'flag': '🇲🇨'},
  {'code': '+976', 'name': 'Mongolia', 'flag': '🇲🇳'},
  {'code': '+382', 'name': 'Montenegro', 'flag': '🇲🇪'},
  {'code': '+1-664', 'name': 'Montserrat', 'flag': '🇲🇸'},
  {'code': '+212', 'name': 'Morocco', 'flag': '🇲🇦'},
  {'code': '+258', 'name': 'Mozambique', 'flag': '🇲🇿'},
  {'code': '+95', 'name': 'Myanmar', 'flag': '🇲🇲'},
  {'code': '+264', 'name': 'Namibia', 'flag': '🇳🇦'},
  {'code': '+674', 'name': 'Nauru', 'flag': '🇳🇷'},
  {'code': '+977', 'name': 'Nepal', 'flag': '🇳🇵'},
  {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
  {'code': '+599', 'name': 'Netherlands Antilles', 'flag': '🇧🇶'},
  {'code': '+687', 'name': 'New Caledonia', 'flag': '🇳🇨'},
  {'code': '+64', 'name': 'New Zealand', 'flag': '🇳🇿'},
  {'code': '+505', 'name': 'Nicaragua', 'flag': '🇳🇮'},
  {'code': '+227', 'name': 'Niger', 'flag': '🇳🇪'},
  {'code': '+234', 'name': 'Nigeria', 'flag': '🇳🇬'},
  {'code': '+683', 'name': 'Niue', 'flag': '🇳🇺'},
  {'code': '+850', 'name': 'North Korea', 'flag': '🇰🇵'},
  {'code': '+1-670', 'name': 'Northern Mariana Islands', 'flag': '🇲🇵'},
  {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
  {'code': '+968', 'name': 'Oman', 'flag': '🇴🇲'},
  {'code': '+92', 'name': 'Pakistan', 'flag': '🇵🇰'},
  {'code': '+680', 'name': 'Palau', 'flag': '🇵🇼'},
  {'code': '+970', 'name': 'Palestine', 'flag': '🇵🇸'},
  {'code': '+507', 'name': 'Panama', 'flag': '🇵🇦'},
  {'code': '+675', 'name': 'Papua New Guinea', 'flag': '🇵🇬'},
  {'code': '+595', 'name': 'Paraguay', 'flag': '🇵🇾'},
  {'code': '+51', 'name': 'Peru', 'flag': '🇵🇪'},
  {'code': '+63', 'name': 'Philippines', 'flag': '🇵🇭'},
  {'code': '+64', 'name': 'Pitcairn', 'flag': '🇵🇳'},
  {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
  {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
  {'code': '+1-787', 'name': 'Puerto Rico', 'flag': '🇵🇷'},
  {'code': '+1-939', 'name': 'Puerto Rico', 'flag': '🇵🇷'},
  {'code': '+974', 'name': 'Qatar', 'flag': '🇶🇦'},
  {'code': '+242', 'name': 'Republic of the Congo', 'flag': '🇨🇬'},
  {'code': '+262', 'name': 'Reunion', 'flag': '🇷🇪'},
  {'code': '+40', 'name': 'Romania', 'flag': '🇷🇴'},
  {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
  {'code': '+250', 'name': 'Rwanda', 'flag': '🇷🇼'},
  {'code': '+590', 'name': 'Saint Barthelemy', 'flag': '🇧🇱'},
  {'code': '+290', 'name': 'Saint Helena', 'flag': '🇸🇭'},
  {'code': '+1-869', 'name': 'Saint Kitts and Nevis', 'flag': '🇰🇳'},
  {'code': '+1-758', 'name': 'Saint Lucia', 'flag': '🇱🇨'},
  {'code': '+590', 'name': 'Saint Martin', 'flag': '🇲🇫'},
  {'code': '+508', 'name': 'Saint Pierre and Miquelon', 'flag': '🇵🇲'},
  {'code': '+1-784', 'name': 'Saint Vincent and the Grenadines', 'flag': '🇻🇨'},
  {'code': '+685', 'name': 'Samoa', 'flag': '🇼🇸'},
  {'code': '+378', 'name': 'San Marino', 'flag': '🇸🇲'},
  {'code': '+239', 'name': 'Sao Tome and Principe', 'flag': '🇸🇹'},
  {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
  {'code': '+221', 'name': 'Senegal', 'flag': '🇸🇳'},
  {'code': '+381', 'name': 'Serbia', 'flag': '🇷🇸'},
  {'code': '+248', 'name': 'Seychelles', 'flag': '🇸🇨'},
  {'code': '+232', 'name': 'Sierra Leone', 'flag': '🇸🇱'},
  {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
  {'code': '+1-721', 'name': 'Sint Maarten', 'flag': '🇸🇽'},
  {'code': '+421', 'name': 'Slovakia', 'flag': '🇸🇰'},
  {'code': '+386', 'name': 'Slovenia', 'flag': '🇸🇮'},
  {'code': '+677', 'name': 'Solomon Islands', 'flag': '🇸🇧'},
  {'code': '+252', 'name': 'Somalia', 'flag': '🇸🇴'},
  {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
  {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
  {'code': '+211', 'name': 'South Sudan', 'flag': '🇸🇸'},
  {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
  {'code': '+94', 'name': 'Sri Lanka', 'flag': '🇱🇰'},
  {'code': '+249', 'name': 'Sudan', 'flag': '🇸🇩'},
  {'code': '+597', 'name': 'Suriname', 'flag': '🇸🇷'},
  {'code': '+47', 'name': 'Svalbard and Jan Mayen', 'flag': '🇸🇯'},
  {'code': '+268', 'name': 'Swaziland', 'flag': '🇸🇿'},
  {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
  {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
  {'code': '+963', 'name': 'Syria', 'flag': '🇸🇾'},
  {'code': '+886', 'name': 'Taiwan', 'flag': '🇹🇼'},
  {'code': '+992', 'name': 'Tajikistan', 'flag': '🇹🇯'},
  {'code': '+255', 'name': 'Tanzania', 'flag': '🇹🇿'},
  {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
  {'code': '+228', 'name': 'Togo', 'flag': '🇹🇬'},
  {'code': '+690', 'name': 'Tokelau', 'flag': '🇹🇰'},
  {'code': '+676', 'name': 'Tonga', 'flag': '🇹🇴'},
  {'code': '+1-868', 'name': 'Trinidad and Tobago', 'flag': '🇹🇹'},
  {'code': '+216', 'name': 'Tunisia', 'flag': '🇹🇳'},
  {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
  {'code': '+993', 'name': 'Turkmenistan', 'flag': '🇹🇲'},
  {'code': '+1-649', 'name': 'Turks and Caicos Islands', 'flag': '🇹🇨'},
  {'code': '+688', 'name': 'Tuvalu', 'flag': '🇹🇻'},
  {'code': '+1-340', 'name': 'U.S. Virgin Islands', 'flag': '🇻🇮'},
  {'code': '+256', 'name': 'Uganda', 'flag': '🇺🇬'},
  {'code': '+380', 'name': 'Ukraine', 'flag': '🇺🇦'},
  {'code': '+971', 'name': 'United Arab Emirates', 'flag': '🇦🇪'},
  {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
  {'code': '+1', 'name': 'United States', 'flag': '🇺🇸'},
  {'code': '+598', 'name': 'Uruguay', 'flag': '🇺🇾'},
  {'code': '+998', 'name': 'Uzbekistan', 'flag': '🇺🇿'},
  {'code': '+678', 'name': 'Vanuatu', 'flag': '🇻🇺'},
  {'code': '+379', 'name': 'Vatican', 'flag': '🇻🇦'},
  {'code': '+58', 'name': 'Venezuela', 'flag': '🇻🇪'},
  {'code': '+84', 'name': 'Vietnam', 'flag': '🇻🇳'},
  {'code': '+681', 'name': 'Wallis and Futuna', 'flag': '🇼🇫'},
  {'code': '+212', 'name': 'Western Sahara', 'flag': '🇪🇭'},
  {'code': '+967', 'name': 'Yemen', 'flag': '🇾🇪'},
  {'code': '+260', 'name': 'Zambia', 'flag': '🇿🇲'},
  {'code': '+263', 'name': 'Zimbabwe', 'flag': '🇿🇼'},
];
