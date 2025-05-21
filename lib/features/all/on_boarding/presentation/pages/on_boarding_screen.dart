import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/txt_theme.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/all/on_boarding/presentation/widgets/custom_page_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  final MustIvestPreferences preferences = sl<MustIvestPreferences>();
  int _currentPage = 0;
  List<String> images = [
    AppIcons.onBoarding1,
    AppIcons.onBoarding2,
    AppIcons.onBoarding3,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip button at the top right
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        preferences.setOnBoardingCompleted();
                        context.pushReplacement(Routes.accountType);
                      },
                      child: Text(
                        LocaleKeys.skip.tr(),
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                // Image section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: SvgPicture.asset(
                      key: ValueKey(_currentPage),
                      fit: BoxFit.fitWidth,
                      images[_currentPage],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Page content
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: CustomPageView(
                    currentPage: _currentPage,
                    pageController: _pageController,
                  ),
                ),

                // Indicators
                AnimatedSmoothIndicator(
                  activeIndex: _currentPage,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.greyED,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      CustomElevatedButton(
                        title: LocaleKeys.login.tr(),
                        // _currentPage == 2
                        //     ? LocaleKeys.get_started.tr()
                        //     : LocaleKeys.next.tr(),
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            preferences.setOnBoardingCompleted();
                            context.pushReplacement(Routes.login);
                          }
                        },
                      ),
                      20.gap,
                      CustomElevatedButton(
                        heroTag: 'create_account',
                        isFilled: false,
                        title: LocaleKeys.create_account.tr(),
                        textColor: null,
                        // _currentPage == 2
                        //     ? LocaleKeys.get_started.tr()
                        //     : LocaleKeys.next.tr(),
                        onPressed: () {
                          preferences.setOnBoardingCompleted();
                          context.pushReplacement(Routes.accountType);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
