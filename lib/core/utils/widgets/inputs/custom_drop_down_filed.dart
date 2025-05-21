import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/sized_box.dart';
import 'package:must_invest/core/static/app_styles.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemLabelBuilder,
    this.hint,
    this.prefixIC,
    this.title,
    this.validator,
    this.shadow,
    this.radius = 50, // More modern radius
    this.margin = 0, // Remove default margin for better layout control
    this.disabled = false,
    this.backgroundColor,
    this.gender = 'male',
    this.isBordered = true,
    this.isRequired = false,
    this.titleStyle,
    this.dropdownItemStyle,
    this.dropdownMenuMaxHeight,
    this.contentPadding,
    this.fieldName,
  });

  final List<T> items;
  final T? value;
  final String Function(T)? itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final Widget? prefixIC;
  final Color? backgroundColor;
  final bool isBordered;
  final String? title;
  final bool disabled;
  final double radius;
  final List<BoxShadow>? shadow;
  final double margin;
  final String? Function(T? value)? validator;
  final bool isRequired;
  final String gender;
  final TextStyle? titleStyle;
  final TextStyle? dropdownItemStyle;
  final double? dropdownMenuMaxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final String? fieldName;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusNode.addListener(() {
      // Update dropdown state based on focus
      setState(() {
        _isDropdownOpen = _focusNode.hasFocus;
      });

      if (_focusNode.hasFocus) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default title style that can be overridden
    final effectiveTitleStyle =
        widget.titleStyle ??
        theme.textTheme.labelMedium?.copyWith(
          color: const Color(0xff2F394E),
          fontSize: 15.r,
          fontWeight: FontWeight.w500,
        );

    // Default item style that can be overridden
    final effectiveItemStyle =
        widget.dropdownItemStyle ??
        AppStyles.medium12black.copyWith(
          fontSize: 15.r,
          color: widget.disabled ? Colors.grey : Colors.black87,
        );

    // Animation for dropdown icon rotation
    final rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Row(
            children: [
              Text(widget.title!, style: effectiveTitleStyle),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: effectiveTitleStyle?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          8.ph,
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),

            boxShadow:
                widget.shadow ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: DropdownButtonFormField2<T>(
            isExpanded: true,

            value: widget.value,
            onChanged: widget.disabled ? null : widget.onChanged,
            dropdownStyleData: DropdownStyleData(
              maxHeight: widget.dropdownMenuMaxHeight ?? 300,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              elevation: 4,
              offset: const Offset(
                0,
                4,
              ), // ensures it shows **below** the field
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  widget.disabled
                      ? Colors.grey.withOpacity(0.1)
                      : widget.backgroundColor ?? Colors.white,
              hintText: widget.hint,
              hintStyle: AppStyles.regular15greyC8.copyWith(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 12.r,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                  color: AppColors.borderColor.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color:
                      (widget.isBordered ?? true)
                          ? AppColors.borderColor
                          : Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
              ),
            ),
            items:
                widget.items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Container(
                      // padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.itemLabelBuilder != null
                            ? widget.itemLabelBuilder!(item)
                            : item.toString(),
                        style: effectiveItemStyle,
                      ),
                    ),
                  );
                }).toList(),
            validator: _compositeValidator,
          ),
        ),
      ],
    );
  }

  String? _compositeValidator(T? value) {
    // Check if the field is required and empty
    if (widget.isRequired && value == null) {
      String genderKey = widget.gender == 'female' ? 'female' : 'male';

      return LocaleKeys.field_is_required.tr(
        namedArgs: {
          "fieldName": (widget.fieldName ?? widget.hint ?? widget.title ?? ''),
          genderKey: widget.gender,
        },
        gender: genderKey,
      );
    }

    // Call the custom validator if one is provided
    if (widget.validator != null) {
      final specificError = widget.validator!(value);
      if (specificError != null) {
        return specificError;
      }
    }

    // If no errors, return null
    return null;
  }
}
