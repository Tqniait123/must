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
import 'package:must_invest/core/utils/dialogs/languages_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/on_boarding/presentation/widgets/custom_page_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// OnBoarding screen with language selection
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  final MustInvestPreferences preferences = sl<MustInvestPreferences>();

  int _currentPage = 0;

  final List<String> _images = [AppIcons.onBoarding1, AppIcons.onBoarding2, AppIcons.onBoarding3];

  @override
  void initState() {
    super.initState();
    _setupPageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called whenever the locale changes
    if (mounted) {
      setState(() {
        // Force rebuild when locale changes
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setupPageController() {
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  void _showLanguageDropdown() {
    showLanguageBottomSheet(context);
  }

  String _getSelectedLanguageFlag() {
    switch (context.locale.languageCode) {
      case 'ar':
        return AppIcons.ar;
      case 'en':
      default:
        return AppIcons.en;
    }
  }

  void _handleNextButton() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _completeOnBoarding(Routes.login);
    }
  }

  void _handleSkip() {
    _completeOnBoarding(Routes.login);
  }

  void _handleCreateAccount() {
    _completeOnBoarding(Routes.register);
  }

  void _completeOnBoarding(String route) {
    try {
      preferences.setOnBoardingCompleted();
      if (mounted) {
        context.pushReplacement(route);
      }
    } catch (error) {
      debugPrint('Error completing onboarding: $error');
    }
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Language selector at top
            _buildTopLanguageBar(),

            // Main content
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLanguageBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          GestureDetector(
            onTap: _handleSkip,
            child: Text(
              LocaleKeys.skip.tr(),
              style: context.textTheme.bodyLarge!.copyWith(color: AppColors.primary.withOpacity(0.8)),
            ),
          ),

          // Language selector
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image section with smooth transitions
            _buildImageSection(),

            const SizedBox(height: 30),

            // Page content
            _buildPageContent(),

            // Page indicators
            _buildPageIndicators(),

            const SizedBox(height: 40),

            // Action buttons
            _buildActionButtons(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: _showLanguageDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  _getSelectedLanguageFlag(),
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Container(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Language code
            Text(
              context.locale.languageCode.toUpperCase(),
              style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),

            // Dropdown arrow
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        child: SvgPicture.asset(key: ValueKey(_currentPage), fit: BoxFit.fitWidth, _images[_currentPage]),
      ),
    );
  }

  Widget _buildPageContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: CustomPageView(currentPage: _currentPage, pageController: _pageController),
    );
  }

  Widget _buildPageIndicators() {
    return AnimatedSmoothIndicator(
      activeIndex: _currentPage,
      count: 3,
      effect: const ExpandingDotsEffect(
        activeDotColor: AppColors.primary,
        dotColor: AppColors.greyED,
        dotHeight: 10,
        dotWidth: 10,
      ),
      onDotClicked: _navigateToPage,
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Main action button (Next/Login)
          CustomElevatedButton(
            title: _currentPage < 2 ? LocaleKeys.next.tr() : LocaleKeys.login.tr(),
            onPressed: _handleNextButton,
          ),

          20.gap,

          // Create account button
          CustomElevatedButton(
            heroTag: 'create_account',
            isFilled: false,
            title: LocaleKeys.create_account.tr(),
            textColor: null,
            onPressed: _handleCreateAccount,
          ),
        ],
      ),
    );
  }
}
