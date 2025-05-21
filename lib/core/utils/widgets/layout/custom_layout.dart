// import 'package:must_invest/config/routes/routes.dart';
// import 'package:must_invest/core/extensions/string_to_icon.dart';
// import 'package:must_invest/core/static/app_assets.dart';
// import 'package:must_invest/core/static/constants.dart';
// import 'package:must_invest/core/static/icons.dart';
// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// class CustomLayout extends StatelessWidget {
//   final List<Widget> children;
//   final bool withPadding;
//   final String? title;
//   final bool? isNotification;
//   final Widget? widget;
//   const CustomLayout({
//     super.key,
//     required this.children,
//     this.title,
//     this.withPadding = true,
//     this.isNotification = false,
//     this.widget,
//   });

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//         const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
//     return Scaffold(
//       // key: Constants.drawerKey, // Assign the GlobalKey here
//       extendBody: true,
//       extendBodyBehindAppBar: true,

//       body: Container(
//         color: AppColors.pattern,
//         alignment: AlignmentDirectional.topStart,
//         child: Stack(
//           fit: StackFit.expand,
//           alignment: AlignmentDirectional.topStart,
//           children: [
//             Hero(
//               tag: 'background',
//               child: SizedBox(
//                 child: Image.asset(
//                   AppImages.background,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 70,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: title != null
//                       ? Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const CustomBackButton(),
//                             widget ??
//                                 Hero(
//                                   tag: 'title',
//                                   child: Text(
//                                     title ?? '',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleLarge!
//                                         .copyWith(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.white),
//                                   ),
//                                 ),
//                             const SizedBox(
//                               width: 40,
//                             ),
//                             if (isNotification == true)
//                               GestureDetector(
//                                   onTap: () {
//                                     context.push(Routes.notification);
//                                   },
//                                   child: AppIcons.notificationsIc.icon())
//                           ],
//                         )
//                       : Hero(
//                           tag: 'header',
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomIconButton(
//                                 color: AppColors.white,
//                                 iconAsset: AppIcons.drawerIc,
//                                 onPressed: () {
//                                   // Open the drawer when the button is pressed
//                                   Constants.drawerKey.currentState
//                                       ?.openDrawer();
//                                 },
//                               ),
//                               FlutterLogo(
//                                 size: 40.r,
//                               ),
//                               GestureDetector(
//                                   onTap: () {
//                                     context.push(Routes.notification);
//                                   },
//                                   child: AppIcons.notificationsIc.icon())
//                             ],
//                           ),
//                         ),
//                 ),
//                 const SizedBox(
//                   height: 18,
//                 ),
//                 Expanded(
//                   child: AnimatedContainer(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(16)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.03),
//                           spreadRadius: 8,
//                           blurRadius: 4,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     duration: const Duration(milliseconds: 700),
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                         top: 16,
//                       ),
//                       child: SingleChildScrollView(
//                         child: withPadding
//                             ? Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: Column(children: children),
//                               )
//                             : Column(children: children),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
