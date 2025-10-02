import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/app.dart';
import 'package:must_invest/core/observers/bloc_observer.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/locales.dart';
import 'package:must_invest/core/translations/codegen_loader.g.dart';
import 'package:must_invest/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> fcmBackgroundHandler(RemoteMessage message) async {
//   // Initialize Firebase in the background isolate
//   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Check if the service is already registered
//   if (!sl.isRegistered<FcmService>()) {
//     // Initialize the dependency injection only if not already registered
//     await initLocator();
//   }
//   // FirebaseMessaging.instance
//   //     .getInitialMessage()
//   //     .then((RemoteMessage? message) {
//   //   if (message != null) {

//   //     Navigator.of(context).pushNamed('/call');
//   //   }
//   // });

//   log('Message received in background: ${message.toMap()}', name: 'FcmService');
//   log('Notification: ${message.notification?.toMap()}', name: 'FcmService');
//   log('Data: ${message.data}', name: 'FcmService');
//   if (Platform.isAndroid) {
//     sl<FcmService>().showNotification(message);
//   }
//   // Use FcmService to show the notification

//   // sl<FcmService>().showNotification(message);
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Initialize SharedPreferences and other dependencies
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize the dependency injection container
  await initLocator(sharedPreferences);
  // await InternetService().initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM
  // FcmService fcmService = FcmService(preferences: sl());
  // await fcmService.initNotifications();
  // FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  Bloc.observer = MyBlocObserver();
  // Set status bar color globally
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Change to your primary color
      statusBarIconBrightness: Brightness.light, // Light icons for dark background
    ),
  );

  // Get the language code from MustInvestPreferences
  // final codeLang = sl<MustInvestPreferences>().getLang();
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [
        Locales.arabic,
        Locales.english,
        // Locales.french,
        // Locales.dutch,
      ],
      startLocale: Locales.arabic,
      fallbackLocale: Locales.arabic,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      child: MustInvest(),
    ),
  );
}
