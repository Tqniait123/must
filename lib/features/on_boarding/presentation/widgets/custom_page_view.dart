import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/txt_theme.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class CustomPageView extends StatelessWidget {
  const CustomPageView({super.key, required int currentPage, required PageController pageController})
    : _currentPage = currentPage,
      _pageController = pageController;

  final int _currentPage;
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pages = [
      {"title": LocaleKeys.welcome.tr(), "description": LocaleKeys.find_a_best_possible_way_to_pa.tr()},
      {"title": LocaleKeys.hollaaa.tr(), "description": LocaleKeys.find_the_best_possible_parking.tr()},
      {"title": LocaleKeys.find_parking.tr(), "description": LocaleKeys.find_your_perfect_parking_spac.tr()},
    ];

    return PageView.builder(
      itemCount: pages.length,
      controller: _pageController,
      itemBuilder:
          (BuildContext context, int index) => Column(
            children: [
              // const SizedBox(height: 48),
              Text(
                pages[index]["title"]!,
                style: context.textTheme.bodyLarge!.copyWith(color: AppColors.primary, fontSize: 25.r),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  pages[index]["description"]!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall!.copyWith(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              // const SizedBox(
              //   height: 48,
              // ),
            ],
          ),
    );
  }
}
