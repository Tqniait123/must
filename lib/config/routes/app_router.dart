// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/observers/router_observer.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/cities_cubit/cities_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/countires_cubit/countries_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/governorates_cubit/governorates_cubit.dart';
import 'package:must_invest/features/auth/presentation/pages/check_your_email_screen.dart';
import 'package:must_invest/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:must_invest/features/auth/presentation/pages/login_screen.dart';
import 'package:must_invest/features/auth/presentation/pages/otp_screen.dart';
import 'package:must_invest/features/auth/presentation/pages/register_screen.dart';
import 'package:must_invest/features/auth/presentation/pages/register_step_three.dart';
import 'package:must_invest/features/auth/presentation/pages/register_step_two.dart';
import 'package:must_invest/features/auth/presentation/pages/reset_password.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/explore/presentation/pages/explore_screen.dart';
import 'package:must_invest/features/explore/presentation/pages/map_screen.dart';
import 'package:must_invest/features/explore/presentation/pages/parking_details_screen.dart';
import 'package:must_invest/features/explore/presentation/pages/routing_parking_screen.dart';
import 'package:must_invest/features/history/presentation/cubit/history_cubit.dart';
import 'package:must_invest/features/history/presentation/pages/history_screen.dart';
import 'package:must_invest/features/home/presentation/pages/home_user.dart';
import 'package:must_invest/features/my_cards/presentation/pages/my_cards_screen.dart';
import 'package:must_invest/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:must_invest/features/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:must_invest/features/profile/presentation/cubit/cars_cubit.dart';
import 'package:must_invest/features/profile/presentation/cubit/pages_cubit.dart';
import 'package:must_invest/features/profile/presentation/pages/about_us_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/contact_us_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/faq_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/my_cars_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/my_qr_code_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/privacy_policy_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/profile_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/scan_qr_code_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/settings_screen.dart';
import 'package:must_invest/features/profile/presentation/pages/terms_and_conditions_screen.dart';
import 'package:must_invest/features/splash/presentation/pages/splash.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

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
        child: _unFoundRoute(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
    observers: [
      routeObserver,
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
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => CountriesCubit(sl())),
              BlocProvider(create: (context) => GovernoratesCubit(sl())),
              BlocProvider(create: (context) => CitiesCubit(sl())),
            ],
            child: const RegisterScreen(),
          );
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
          final extras = state.extra as Map<String, dynamic>;
          return OtpScreen(phone: extras['phone'] as String, flow: extras['flow'] as OtpFlow);
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) {
          // Return the OtpScreen widget
          return ResetPasswordScreen(phone: state.extra as String);
        },
      ),
      GoRoute(
        path: Routes.homeUser,
        builder: (context, state) {
          // Return the HomeUser widget
          return const HomeUser();
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
      GoRoute(
        path: Routes.explore,
        builder: (context, state) {
          // Return the ExploreScreen widget
          return ExploreScreen();
        },
      ),
      GoRoute(
        path: Routes.maps,
        builder: (context, state) {
          // Return the MapsScreen widget
          return BlocProvider(create: (BuildContext context) => ExploreCubit(sl()), child: MapScreen());
        },
      ),
      GoRoute(
        path: Routes.parkingDetails,
        builder: (context, state) {
          // Return the ParkingDetails widget
          return ParkingDetailsScreen(parking: state.extra as Parking);
        },
      ),
      GoRoute(
        path: Routes.routing,
        builder: (context, state) {
          // Return the Routing widget
          return RoutingParkingScreen(parking: state.extra as Parking);
        },
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) {
          // Return the Routing widget
          return NotificationsScreen();
        },
      ),
      GoRoute(
        path: Routes.myCards,
        builder: (context, state) {
          // Return the MyCardsScreen widget
          return MyCardsScreen();
        },
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) {
          // Return the ProfileScreen widget
          return ProfileScreen();
        },
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) {
          // Return the EditProfileScreen widget
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => CountriesCubit(sl())),
              BlocProvider(create: (context) => GovernoratesCubit(sl())),
              BlocProvider(create: (context) => CitiesCubit(sl())),
            ],
            child: EditProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.myQrCode,
        builder: (context, state) {
          // Return the MyQrCodeScreen widget
          return MyQrCodeScreen(car: state.extra as Car);
        },
      ),
      GoRoute(
        path: Routes.history,
        builder: (context, state) {
          // Return the HistoryScreen widget
          return BlocProvider(create: (BuildContext context) => HistoryCubit(sl()), child: const HistoryScreen());
        },
      ),
      GoRoute(
        path: Routes.scanQrcode,
        builder: (context, state) {
          // Return the ScanQrcodeScreen widget
          return ScanQrCodeScreen(selectedCar: state.extra as Car);
        },
      ),
      GoRoute(
        path: Routes.myCars,
        builder: (context, state) {
          // Return the MyCarsScreen widget
          return BlocProvider(create: (BuildContext context) => CarCubit(sl()), child: MyCarsScreen());
        },
      ),
      GoRoute(
        path: Routes.faq,
        builder: (context, state) {
          // Return the FAQscreen widget
          return BlocProvider(create: (BuildContext context) => PagesCubit(sl()), child: FAQScreen());
        },
      ),
      GoRoute(
        path: Routes.termsAndConditions,
        builder: (context, state) {
          // Return the TermsAnsConditionsScreen widget
          return BlocProvider(create: (BuildContext context) => PagesCubit(sl()), child: TermsAndConditionsScreen());
        },
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        builder: (context, state) {
          // Return the TermsAnsConditionsScreen widget
          return BlocProvider(create: (BuildContext context) => PagesCubit(sl()), child: PrivacyPolicyScreen());
        },
      ),
      GoRoute(
        path: Routes.contactUs,
        builder: (context, state) {
          // Return the TermsAnsConditionsScreen widget
          return BlocProvider(create: (BuildContext context) => PagesCubit(sl()), child: ContactUsScreen());
        },
      ),
      GoRoute(
        path: Routes.aboutUs,
        builder: (context, state) {
          // Return the AboutUsScreen widget
          return BlocProvider(create: (BuildContext context) => PagesCubit(sl()), child: AboutUsScreen());
        },
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) {
          // Return the SettingsScreen widget
          return SettingsScreen();
        },
      ),
    ],
  );

  // Define a static method for the "Un Found Route" page
  static Widget _unFoundRoute(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBackButton(),
            100.gap,
            Center(child: Text("Un Found Route", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
          ],
        ),
      ).paddingHorizontal(24),
    );
  }

  @override
  List<Object?> get props => [router];
}
