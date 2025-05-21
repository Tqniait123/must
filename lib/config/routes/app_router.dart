// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/observers/router_observer.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/features/all/auth/presentation/pages/account_type_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/check_your_email_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/forget_password_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/login_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/otp_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/register_screen.dart';
import 'package:must_invest/features/all/auth/presentation/pages/register_step_three.dart';
import 'package:must_invest/features/all/auth/presentation/pages/register_step_two.dart';
import 'package:must_invest/features/all/auth/presentation/pages/reset_password.dart';
import 'package:must_invest/features/all/layout/presentation/pages/layout_parent.dart';
import 'package:must_invest/features/all/layout/presentation/pages/layout_teen.dart';
import 'package:must_invest/features/all/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:must_invest/features/all/splash/presentation/pages/splash.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Define the AppRouter class
class AppRouter {
  // Create a GoRouter instance
  final GoRouter router = GoRouter(
    initialLocation: Routes.initialRoute,
    navigatorKey: rootNavigatorKey,
    errorPageBuilder: (context, state) {
      return CustomTransitionPage(
        transitionDuration: const Duration(milliseconds: 200),
        key: state.pageKey,
        child: _unFoundRoute(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
    observers: [
      GoRouterObserver(), // Specify your observer here
    ],
    routes: [
      // Define routes using GoRoute
      GoRoute(
        path: Routes.initialRoute,
        builder: (context, state) {
          // Return the SplashScreen widget
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: Routes.onBoarding1,
        builder: (context, state) {
          // Return the SplashScreen widget
          return const OnBoardingScreen();
        },
      ),
      GoRoute(
        path: Routes.accountType,
        builder: (context, state) {
          // Return the AccountTypeScreen widget
          return const AccountTypeScreen();
        },
      ),

      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          // Return the SplashScreen widget
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) {
          // Return the RegisterScreen widget
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: Routes.forgetPassword,
        builder: (context, state) {
          // Return the ForgetPasswordScreen widget
          return const ForgetPasswordScreen();
        },
      ),
      GoRoute(
        path: Routes.otpScreen,
        builder: (context, state) {
          // Return the OtpScreen widget
          return OtpScreen(phone: state.extra as String);
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) {
          // Return the OtpScreen widget
          return ResetPasswordScreen(email: state.extra as String);
        },
      ),
      GoRoute(
        path: Routes.layoutParent,
        builder: (context, state) {
          // Return the Layout widget
          return const LayoutParent();
        },
      ),
      GoRoute(
        path: Routes.layoutTeen,
        builder: (context, state) {
          // Return the Layout widget
          return const LayoutTeen();
        },
      ),
      GoRoute(
        path: Routes.registerStepTwo,
        builder: (context, state) {
          // Return the RegisterStepTwoScreen widget
          return const RegisterStepTwoScreen();
        },
      ),
      GoRoute(
        path: Routes.registerStepThree,
        builder: (context, state) {
          // Return the RegisterStepThreeScreen widget
          return const RegisterStepThreeScreen();
        },
      ),
      GoRoute(
        path: Routes.checkYourEmail,
        builder: (context, state) {
          // Return the CheckYourEmailScreen widget
          return CheckYourEmailScreen(email: state.extra as String);
        },
      ),
    ],
  );

  // Define a static method for the "Un Found Route" page
  static Widget _unFoundRoute() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBackButton(),
            100.gap,
            Center(
              child: Text(
                "Un Found Route",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ).paddingHorizontal(24),
    );
  }

  @override
  List<Object?> get props => [router];
}
