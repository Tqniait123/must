import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/auth/presentation/languages_cubit/languages_cubit.dart';

void showLanguageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isScrollControlled: true,
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(LocaleKeys.select_language.tr(), style: context.textTheme.titleLarge!.semiBold),
                  ),

                  // Language options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        _LanguageOption(
                          flag: AppIcons.en, // Your SVG icon
                          language: 'English',
                          languageCode: 'en',
                          isSelected: context.locale.languageCode == 'en',
                          onTap: () {
                            context.read<LanguagesCubit>().setLanguage(context, 'en');
                            Navigator.pop(context);
                          },
                        ),
                        8.gap,
                        _LanguageOption(
                          flag: AppIcons.ar, // Your SVG icon for Arabic
                          language: 'العربية',
                          languageCode: 'ar',
                          isSelected: context.locale.languageCode == 'ar',
                          onTap: () {
                            context.read<LanguagesCubit>().setLanguage(context, 'ar');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  24.gap,
                ],
              ),
            );
          },
        ),
  );
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String language;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.language,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1) : null,
          ),
          child: Row(
            children: [
              // Flag icon
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[50]),
                child: SvgPicture.asset(flag, width: 24, height: 24, fit: BoxFit.contain),
              ),

              16.gap,

              // Language name
              Expanded(
                child: Text(
                  language,
                  style: context.textTheme.bodyLarge!.copyWith(
                    color: isSelected ? AppColors.primary : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),

              // Check indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
