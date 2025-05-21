// import 'package:flutter/material.dart';

// extension AppNavigator on BuildContext {
//   void navigateTo({required String routeName, Object? arguments}) {
//     Navigator.pushNamed(this, routeName, arguments: arguments);
//   }

//   void navigateAndReplacement({required String newRoute, Object? arguments}) {
//     Navigator.pushReplacementNamed(this, newRoute, arguments: arguments);
//   }

//   Future<Object?> navigateAndRemoveUntil({
//     required String newRoute,
//     Object? arguments,
//   }) {
//     return Navigator.pushNamedAndRemoveUntil(
//       this,
//       newRoute,
//       (Route<dynamic> route) => false, // remove all previous routes
//       arguments: arguments,
//     );
//   }

//   void getBack() {
//     Navigator.pop(this);
//   }

//   // Your new functions
//   void navigateWithFade({
//     required Widget page,
//     Duration? delay,
//   }) {
//     Future.delayed(delay = const Duration(milliseconds: 0), () {
//       Navigator.push(
//         this,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) => page,
//           transitionDuration: const Duration(milliseconds: 200),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//         ),
//       );
//     });
//   }

//   void navigateAndReplaceWithFade({
//     required Widget page,
//     Duration? delay = const Duration(milliseconds: 0),
//     Duration? transitionDuration = const Duration(milliseconds: 200),
//   }) {
//     Future.delayed(delay!, () {
//       Navigator.pushReplacement(
//         this,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) => page,
//           transitionDuration: transitionDuration!,
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//         ),
//       );
//     });
//   }
// }
