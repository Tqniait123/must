import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/loading_widget.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _positionController;
  late AnimationController _logoFadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _positionAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation for welcome message
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Setup fade animation for logo
    _logoFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_logoFadeController);

    // Setup position animation for logo - match duration with fade animation
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 800), // Match fade duration
      vsync: this,
    );
    _positionAnimation = Tween<double>(begin: 0.0, end: -20.0).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeOut),
    );

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Wait for initial delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Start logo fade animation
    _logoFadeController.forward();

    // Wait 2 seconds before showing welcome message and moving logo
    await Future.delayed(const Duration(seconds: 2));

    // Start both animations simultaneously
    _fadeController.forward();
    _positionController.forward();

    // Wait 1 second after animations complete and check navigation
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      await _handleNavigation();
    }
  }

  Future<void> _handleNavigation() async {
    final pref = MustInvestPreferences(sl());
    final bool isOnBoardingCompleted = pref.isOnBoardingCompleted();

    if (!isOnBoardingCompleted) {
      // Navigate to onboarding if not completed
      context.go(Routes.onBoarding1);
      return;
    }

    // If onboarding is completed, try auto login
    try {
      await context.read<AuthCubit>().autoLogin();
    } catch (e) {
      // If auto login fails, navigate to login screen
      if (mounted) {
        context.go(Routes.login);
      }
    }
  }

  void _listenToAuthState() {
    context.read<AuthCubit>().stream.listen((state) {
      if (!mounted) return;

      if (state is AuthSuccess) {
        // Auto login successful, navigate to main/home screen
        context.setCurrentUser(state.user);
        context.go(Routes.homeUser); // Replace with your main screen route
      } else if (state is AuthError) {
        // Auto login failed, navigate to login screen
        context.go(Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _positionController.dispose();
    _logoFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    _listenToAuthState();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -300, // Shift pattern to the left
                child: Opacity(
                  opacity: 0.3,
                  child: AppIcons.splashPattern.svg(
                    width: MediaQuery.sizeOf(context).width * 1.2,
                    height: MediaQuery.sizeOf(context).height * 1.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with position change and fade
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: AnimatedBuilder(
                        animation: _positionAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _positionAnimation.value),
                            child: child,
                          );
                        },
                        child: LogoWidget(type: LogoType.svg),
                      ),
                    ),
                    44.gap,
                    // Fade in animation for welcome message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            LocaleKeys.welcome_to_must_invest.tr(),
                            style: context.bodyLarge.bold.s16.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          if (state is AuthLoading) ...[
                            16.gap,
                            CustomLoadingWidget(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
