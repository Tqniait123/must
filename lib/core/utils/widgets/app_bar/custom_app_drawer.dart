// import 'package:must_invest/config/routes/routes.dart';
// import 'package:must_invest/core/static/icons.dart';
// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/utils/dialogs/support_dialog.dart';
// import 'package:must_invest/core/utils/widgets/app_bar/drawer_item.dart';
// import 'package:must_invest/features/auth/user_cubit/user_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// class CustomAppDrawer extends StatefulWidget {
//   const CustomAppDrawer({super.key});

//   @override
//   State<CustomAppDrawer> createState() => _CustomAppDrawerState();
// }

// class _CustomAppDrawerState extends State<CustomAppDrawer> {
//   int selectedIndex = 0; // Add a selected index state

//   @override
//   Widget build(BuildContext context) {
//     final user = context.user;
//     return Drawer(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             SizedBox(height: 50.h),
//             Row(
//               children: <Widget>[
//                 CircleAvatar(
//                   radius: 30.0,
//                   backgroundColor: AppColors.primary,
//                   child: Text(
//                     user?.fullName.substring(0, 2) ??
//                         '', // Replace with logic to get the first two characters dynamically
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16.r,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Text(user?.fullName ?? '',
//                         style: TextStyle(
//                             fontWeight: FontWeight.w700, fontSize: 15.r)),
//                     const SizedBox(height: 8),
//                     Text(
//                       user?.phone ?? '',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 11.r,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             DrawerItem(
//               title: 'معلومات الحساب',
//               icon: AppIcons.profileIc,
//               isSelected: selectedIndex == 0, // Highlight if selected
//               onTap: () {
//                 setState(() => selectedIndex = 0);
//                 context.push(Routes.accountInfo);
//               },
//             ),
//             DrawerItem(
//               title: 'احصائياتي',
//               icon: AppIcons.statisticsIc,
//               isSelected: selectedIndex == 1,
//               onTap: () {
//                 setState(() => selectedIndex = 1);
//                 context.push(Routes.statistics);
//               },
//             ),
//             DrawerItem(
//               icon: AppIcons.contactIc,
//               title: 'الدعم',
//               isSelected: selectedIndex == 2,
//               onTap: () {
//                 setState(() => selectedIndex = 2);
//                 showSupportDialog(context); // Show dialog
//               },
//             ),
//             DrawerItem(
//               icon: AppIcons.languageIc,
//               title: 'عنا',
//               isSelected: selectedIndex == 3,
//               onTap: () {
//                 setState(() => selectedIndex = 3);
//                 context.push(Routes.aboutUs);
//               },
//             ),
//             DrawerItem(
//               title: 'تسجيل الخروج',
//               icon: AppIcons.logoutIc,
//               isSelected: selectedIndex == 4,
//               onTap: () {
//                 context.go(Routes.login);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
