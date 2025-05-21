import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/config/routes/app_router.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/strings.dart';
import 'package:must_invest/core/theme/light_theme.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/languages_cubit/languages_cubit.dart';

class MustIvest extends StatelessWidget {
  MustIvest({super.key});
  final AppRouter appRouter = AppRouter(); // Create an instance of AppRouter

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (BuildContext context) => AuthCubit(sl())),
            BlocProvider(create: (BuildContext context) => UserCubit()),
            BlocProvider(create: (context) => LanguagesCubit(sl())),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            title: Strings.appName,
            theme: lightTheme(context),
            builder: (context, child) {
              child = BotToastInit()(context, child);
              return Scaffold(
                body: child,
                floatingActionButton:
                    kDebugMode
                        ? Opacity(
                          opacity: 0.1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: FloatingActionButton(
                              child: const Icon(Icons.refresh),
                              onPressed: () async {
                                await context.setLocale(
                                  const Locale('en'),
                                ); // Reload translations
                                await context.setLocale(
                                  const Locale('ar'),
                                ); // Reload translations
                              },
                            ),
                          ),
                        )
                        : null,
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
