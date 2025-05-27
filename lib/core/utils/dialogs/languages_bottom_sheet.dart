import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
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
            return SingleChildScrollView(
              child: Wrap(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle small line on top
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          LocaleKeys.select_language.tr(),
                          style: context.textTheme.bodyMedium!.bold.s24,
                        ),
                        20.gap,
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            'English',
                            style: context.textTheme.bodyMedium!.regular.s16,
                          ),
                          trailing:
                              context.locale.languageCode == 'en'
                                  ? Icon(Icons.check, color: AppColors.primary)
                                  : null,
                          onTap: () {
                            context.read<LanguagesCubit>().setLanguage(
                              context,
                              'en',
                            );
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            'العربية',
                            style: context.textTheme.bodyMedium!.regular.s16,
                          ),
                          trailing:
                              context.locale.languageCode == 'ar'
                                  ? Icon(Icons.check, color: AppColors.primary)
                                  : null,
                          onTap: () {
                            context.read<LanguagesCubit>().setLanguage(
                              context,
                              'ar',
                            );
                            Navigator.pop(context);
                          },
                        ),
                        16.gap,
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
  );
}
