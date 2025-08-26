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

/// Enhanced OnBoarding screen with integrated language selection
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // =============================================================================
  // CONTROLLERS & SERVICES
  // =============================================================================

  final PageController _pageController = PageController();
  final MustInvestPreferences preferences = sl<MustInvestPreferences>();

  // =============================================================================
  // STATE VARIABLES
  // =============================================================================

  int _currentPage = 0;
  String _selectedLanguage = 'en';
  bool _isLanguageChanging = false;

  // =============================================================================
  // CONSTANTS & CONFIGURATION
  // =============================================================================

  // OnBoarding images
  final List<String> _images = [AppIcons.onBoarding1, AppIcons.onBoarding2, AppIcons.onBoarding3];

  // =============================================================================
  // LIFECYCLE METHODS
  // =============================================================================

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
    _setupPageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =============================================================================
  // INITIALIZATION METHODS
  // =============================================================================

  /// Initialize the selected language from current locale
  void _initializeLanguage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedLanguage = context.locale.languageCode;
        });
      }
    });
  }

  /// Setup page controller listener
  void _setupPageController() {
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  // =============================================================================
  // LANGUAGE MANAGEMENT
  // =============================================================================

  /// Show language dropdown menu positioned below the selector
  void _showLanguageDropdown() {
    showLanguageBottomSheet(context);
  }

  /// Build minimal language menu item widget
  Widget _buildMinimalLanguageItem({required String code, required String flagAsset, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flag
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: SvgPicture.asset(
                flagAsset,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => Container(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Language code
          Text(
            code.toUpperCase(),
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),

          const SizedBox(width: 4),

          // Minimal selection indicator
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// Get the flag asset for the currently selected language
  String _getSelectedLanguageFlag() {
    switch (_selectedLanguage) {
      case 'ar':
        return AppIcons.ar;
      case 'en':
      default:
        return AppIcons.en;
    }
  }

  /// Handle language change with EasyLocalization
  Future<void> _handleLanguageChange(String languageCode) async {
    if (_selectedLanguage == languageCode || _isLanguageChanging) return;

    setState(() {
      _isLanguageChanging = true;
    });

    try {
      // Change language using EasyLocalization
      await context.setLocale(Locale(languageCode));

      // Optional: Save language preference for persistence
      // You can add this to your MustInvestPreferences if needed
      // await preferences.setSelectedLanguage(languageCode);

      setState(() {
        _selectedLanguage = languageCode;
      });

      // Show success message (optional)
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(LocaleKeys.language_changed_successfully.tr()),
      //       backgroundColor: AppColors.primary,
      //       duration: const Duration(seconds: 2),
      //     ),
      //   );
      // }
    } catch (error) {
      debugPrint('Error changing language: $error');

      // // Show error message
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to change language. Please try again.'),
      //       backgroundColor: Colors.red,
      //       duration: const Duration(seconds: 2),
      //     ),
      //   );
      // }
    } finally {
      if (mounted) {
        setState(() {
          _isLanguageChanging = false;
        });
      }
    }
  }

  // =============================================================================
  // NAVIGATION METHODS
  // =============================================================================

  /// Navigate to next page or complete onboarding
  void _handleNextButton() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _completeOnBoarding(Routes.login);
    }
  }

  /// Skip onboarding and go to login
  void _handleSkip() {
    _completeOnBoarding(Routes.login);
  }

  /// Go to register screen
  void _handleCreateAccount() {
    _completeOnBoarding(Routes.register);
  }

  /// Complete onboarding and navigate to specified route
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

  /// Navigate to specific page via indicator
  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  // =============================================================================
  // BUILD METHOD
  // =============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _buildMainContent(),

            // Language selector positioned at top left
            _buildLanguageSelector(),

            // Loading overlay when changing language
            if (_isLanguageChanging) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // UI BUILDING METHODS
  // =============================================================================

  /// Build the main scrollable content
  Widget _buildMainContent() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip button at the top right
            _buildSkipButton(),

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

  /// Build language selector positioned at top left
  Widget _buildLanguageSelector() {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: _isLanguageChanging ? null : () => _showLanguageDropdown(),
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
                _selectedLanguage.toUpperCase(),
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),

              // Dropdown arrow or loading
              if (_isLanguageChanging)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                  ),
                )
              else
                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build skip button
  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _handleSkip,
          child: Text(
            LocaleKeys.skip.tr(),
            style: context.textTheme.bodyLarge!.copyWith(
              color: AppColors.primary.withOpacity(0.8),
              // fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Build image section with animated transitions
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

  /// Build page content section
  Widget _buildPageContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: CustomPageView(currentPage: _currentPage, pageController: _pageController),
    );
  }

  /// Build page indicators
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

  /// Build action buttons section
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Main action button (Next/Login)
          CustomElevatedButton(
            title: _currentPage < 2 ? LocaleKeys.next.tr() : LocaleKeys.login.tr(),
            onPressed: _isLanguageChanging ? null : _handleNextButton,
          ),

          20.gap,

          // Create account button
          CustomElevatedButton(
            heroTag: 'create_account',
            isFilled: false,
            title: LocaleKeys.create_account.tr(),
            textColor: null,
            onPressed: _isLanguageChanging ? null : _handleCreateAccount,
          ),
        ],
      ),
    );
  }

  /// Build loading overlay when changing language
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
              const SizedBox(height: 16),
              Text(
                'Changing language...', // You can add this to your LocaleKeys
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
