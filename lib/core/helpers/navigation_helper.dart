// import 'package:flutter/material.dart';

// class NavigationHelper {
//   static void navigateAndReplaceWithFade(
//       BuildContext context, Widget page, Duration delay) {
//     Future.delayed(delay, () {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) => page,
//           transitionDuration: const Duration(milliseconds: 1500),
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

//   static void navigateWithFade(
//       BuildContext context, Widget page, Duration delay) {
//     Future.delayed(delay, () {
//       Navigator.push(
//         context,
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
// }
