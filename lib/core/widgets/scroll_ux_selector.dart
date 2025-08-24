// lib/core/widgets/scroll_ux_selector.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';

import '../enums/scroll_ux_option.dart';

class ScrollUXSelector extends StatelessWidget {
  const ScrollUXSelector({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    this.title = 'Scroll UX Options (Testing)',
    this.spacing = 8.0,
    this.showTitle = true,
    this.titleGap = 4.0,
  });

  final ScrollUXOption? selectedOption;
  final ValueChanged<ScrollUXOption> onOptionSelected;
  final String title;
  final double spacing;
  final bool showTitle;
  final double titleGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (showTitle) ...[Text(title, style: context.bodySmall.bold), SizedBox(height: titleGap)],
          Wrap(
            spacing: spacing,
            children:
                ScrollUXOption.values.map((option) {
                  return ChoiceChip(
                    label: Text('${option.value}'),
                    selected: selectedOption == option,
                    onSelected: (selected) {
                      if (selected) {
                        onOptionSelected(option);
                      }
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
