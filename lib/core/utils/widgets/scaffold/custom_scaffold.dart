// import 'package:flutter/material.dart';
// import 'package:must_invest/config/routes/app_router.dart';
// import 'package:must_invest/core/extensions/context_extensions.dart';
// import 'package:must_invest/core/static/app_assets.dart';
// import 'package:must_invest/core/theme/colors.dart';

// class CustomScaffold extends Scaffold {
//   CustomScaffold({
//     super.key,
//     super.appBar,
//     Widget? body,
//     bool showBackgroundIcon = false,
//     super.floatingActionButton,
//     super.floatingActionButtonLocation,
//     super.floatingActionButtonAnimator,
//     super.persistentFooterButtons,
//     super.drawer,
//     super.endDrawer,
//     super.bottomNavigationBar,
//     super.bottomSheet,
//     super.backgroundColor,
//     super.resizeToAvoidBottomInset,
//     super.primary,
//     super.extendBody,
//     super.extendBodyBehindAppBar = true,
//   }) : super(body: _buildBody(body, showBackgroundIcon, appBar != null));

//   static Widget? _buildBody(Widget? body, bool showBackgroundIcon, bool show) {
//     final context = rootNavigatorKey.currentContext!;
//     return RepaintBoundary(
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // AppImages.blurredImage.toImage(
//           //   width: MediaQuery.of(context).size.width,
//           // ),
//           PositionedDirectional(
//             top: -250,
//             start: -300,
//             child: Hero(
//               tag: 'background',
//               child: Image.asset(
//                 AppImages.blurredImage,
//                 // width: MediaQuery.of(context).size.width + 200,
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
//           ),
//           // Hero(tag: 'background', child: const BlurredBackgroundCircle()),
//           // Hero(
//           //   tag: 'background2',
//           //   child: const BlurredBackgroundCircle(
//           //     top: -90,
//           //     start: 150,
//           //     color: Color(0x00d9e5ff),
//           //   ),
//           // ),
//           if (show)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: kToolbarHeight + context.statusBarHeight,
//               child: Container(color: AppColors.gradient),
//             ),
//           if (body != null) body,
//         ],
//       ),
//     );
//   }
// }
