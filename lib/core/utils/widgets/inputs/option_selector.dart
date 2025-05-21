import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/sized_box.dart';
import 'package:must_invest/core/extensions/txt_theme.dart';
import 'package:must_invest/core/theme/colors.dart';

class OptionSelector<T> extends StatelessWidget {
  final List<T> options;
  final void Function(T option)? onChanged;
  final String? title;
  final String Function(T option)? formatOption;
  final String? Function(T? option)? validator;
  final bool showValidation;

  final T? value;

  const OptionSelector({
    super.key,
    required this.options,
    this.onChanged,
    this.title,
    this.formatOption,
    this.value,
    this.validator,
    this.showValidation = false,
  });

  @override
  Widget build(BuildContext context) {
    String? validationMessage = validator?.call(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title ?? '',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.grey4A),
          ),
          8.ph,
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildRows(context),
            ),

            // Add a Text widget to display the validation message.
            if (validationMessage != null && showValidation)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  validationMessage,
                  style: context.textTheme.bodySmall!.copyWith(
                    color: Colors.red[600],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    List<Widget> rows = [];
    for (int i = 0; i < options.length; i += 2) {
      Widget leftOption = _buildOption(context, i);
      Widget rightOption =
          i + 1 < options.length
              ? _buildOption(context, i + 1)
              : const SizedBox();

      rows.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Row(children: [leftOption, rightOption]),
        ),
      );
    }

    return rows;
  }

  Widget _buildOption(BuildContext context, int index) {
    bool isLight = context.theme.scaffoldBackgroundColor == AppColors.whiteFD;

    final T option = options[index];
    final isSelected = option == value;
    final selectedColor =
        isLight
            ? (isSelected
                ? Theme.of(context).colorScheme.primary
                : AppColors.white)
            : (isSelected
                ? Theme.of(context).colorScheme.primary
                : AppColors.black);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50.0.h,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(),
          ),
          child: MaterialButton(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0.r),
            ),
            onPressed: () {
              if (option == value) {
                // The same option is being clicked, so unselect it.
                onChanged?.call(option);
              } else {
                // A different option is being clicked, select it.
                onChanged?.call(option);
              }
              // onChanged?.call(option);
            },
            child: Text(
              formatOption?.call(option).tr() ?? "$option".tr(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color:
                    isLight
                        ? (isSelected ? Colors.white : AppColors.black)
                        : (isSelected ? AppColors.black : AppColors.white),
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
