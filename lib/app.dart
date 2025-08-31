import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/config/app_settings/cubit/settings_cubit.dart';
import 'package:must_invest/config/routes/app_router.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/strings.dart';
import 'package:must_invest/core/theme/light_theme.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/languages_cubit/languages_cubit.dart';

class MustInvest extends StatelessWidget {
  const MustInvest({super.key});
  // final AppRouter appRouter = AppRouter(); // Create an instance of AppRouter

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      // Force ScreenUtil to ignore device text scale factor
      fontSizeResolver: (fontSize, instance) => fontSize.toDouble(),
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (BuildContext context) => AuthCubit(sl())),
            BlocProvider(create: (BuildContext context) => UserCubit()),
            BlocProvider(create: (context) => LanguagesCubit(sl())),
            BlocProvider(create: (context) => AppSettingsCubit(sl())),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            title: Strings.appName,
            theme: lightTheme(context),
            builder: (context, child) {
              // Get original MediaQuery data
              final originalData = MediaQuery.of(context);

              // Override scaling but preserve keyboard handling
              child = MediaQuery(
                data: originalData.copyWith(
                  textScaler: const TextScaler.linear(1),
                  // Remove devicePixelRatio modification to fix keyboard issue
                  // devicePixelRatio: 0.8, // This causes keyboard layout issues
                ),
                child: child!,
              );

              child = BotToastInit()(context, child);

              // Remove the Scaffold wrapper - it causes keyboard issues
              return Stack(
                children: [
                  child,
                  if (kDebugMode)
                    Positioned(
                      bottom: 100,
                      right: 16,
                      child: Opacity(
                        opacity: 0.1,
                        child: FloatingActionButton(
                          child: const Icon(Icons.refresh),
                          onPressed: () async {
                            await context.setLocale(const Locale('en')); // Reload translations
                            await context.setLocale(const Locale('ar')); // Reload translations
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
            // routerConfig: appRouter.router,
            routeInformationParser: appRouter.router.routeInformationParser,
            routeInformationProvider: appRouter.router.routeInformationProvider,
            routerDelegate: appRouter.router.routerDelegate,
            backButtonDispatcher: RootBackButtonDispatcher(),

            // home: const SplashScreen(),
          ),
        );
      },
    );
  }

  // final GoRouter _router = GoRouter
}

final AppRouter appRouter = AppRouter(); // Create an instance of AppRouter
