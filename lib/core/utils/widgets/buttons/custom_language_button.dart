// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:must_invest/core/preferences/shared_pref.dart';
// import 'package:must_invest/core/services/di.dart';
// import 'package:must_invest/features/auth/presentation/languages_cubit/languages_cubit.dart';

// class CustomLanguageDropDownButton extends StatefulWidget {
//   final String initialLanguage;
//   final ValueChanged<String> onChanged;
//   final BoxShadow? boxShadow;
//   final Color color;
//   final Color borderColor;
//   final bool isBordered;

//   const CustomLanguageDropDownButton({
//     super.key,
//     required this.initialLanguage,
//     required this.onChanged,
//     this.boxShadow,
//     this.color = Colors.transparent,
//     this.borderColor = Colors.white,
//     this.isBordered = false,
//   });

//   @override
//   State<CustomLanguageDropDownButton> createState() =>
//       _CustomLanguageDropDownButtonState();
// }

// class _CustomLanguageDropDownButtonState
//     extends State<CustomLanguageDropDownButton> {
//   late String selectedLanguage;

//   final Map<String, String> languageMap = {'en': 'En', 'ar': 'ع'};

//   final Map<String, String> flagMap = {
//     'en': 'assets/images/photos/flag_us.png',
//     'ar': 'assets/images/photos/flag_sa.png',
//   };

//   @override
//   void initState() {
//     super.initState();
//     selectedLanguage = widget.initialLanguage;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LanguagesCubit, LanguagesState>(
//       builder: (context, state) {
//         if (state is LanguagesUpdated) {
//           selectedLanguage = state.langCode;
//         } else if (selectedLanguage.isEmpty) {
//           selectedLanguage = sl<MustIvestPreferences>().getLang();
//         }

//         return Animate(
//           effects: [
//             FadeEffect(duration: 300.ms),
//             ScaleEffect(duration: 300.ms),
//           ],
//           child: Container(
//             height: 55.h,
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             decoration: BoxDecoration(
//               color: widget.color,
//               borderRadius: BorderRadius.circular(14.0.r),
//               boxShadow: widget.boxShadow != null ? [widget.boxShadow!] : [],
//               border:
//                   widget.isBordered
//                       ? Border.all(color: widget.borderColor, width: 1.2)
//                       : null,
//             ),
//             child: PopupMenuButton<String>(
//               initialValue: selectedLanguage,
//               offset: Offset(0, 55.h),
//               color: Colors.white.withAlpha(200),
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14.r),
//               ),
//               onSelected: (String newValue) {
//                 setState(() {
//                   selectedLanguage = newValue;
//                 });
//                 context.read<LanguagesCubit>().setLanguage(context, newValue);
//                 widget.onChanged(newValue);
//               },
//               itemBuilder: (BuildContext context) {
//                 return languageMap.keys.map((String key) {
//                   return PopupMenuItem<String>(
//                     value: key,
//                     height: 45.h,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 28.w,
//                           height: 28.h,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 2,
//                                 spreadRadius: 1,
//                               ),
//                             ],
//                           ),
//                           child: ClipOval(
//                             child: Image.asset(
//                               flagMap[key]!,
//                               width: 24.w,
//                               height: 24.h,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Text(
//                           languageMap[key]!,
//                           style: TextStyle(
//                             fontSize: 16.r,
//                             fontWeight:
//                                 key == selectedLanguage
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         if (key == selectedLanguage)
//                           Padding(
//                             padding: EdgeInsets.only(left: 8.w),
//                             child: Icon(
//                               Icons.check_circle,
//                               color: Theme.of(context).primaryColor,
//                               size: 16.sp,
//                             ),
//                           ),
//                         if (key != selectedLanguage)
//                           Padding(
//                             padding: EdgeInsets.only(left: 8.w),
//                             child: Icon(
//                               Icons.check_circle_outline,
//                               color: Colors.grey,
//                               size: 16.sp,
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 }).toList();
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 24.w,
//                         height: 24.h,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 2,
//                               spreadRadius: 1,
//                             ),
//                           ],
//                         ),
//                         child: ClipOval(
//                           child: Image.asset(
//                             flagMap[selectedLanguage]!,
//                             width: 24.w,
//                             height: 24.h,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Text(
//                         languageMap[selectedLanguage]!,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 12.w),
//                   Container(
//                     padding: EdgeInsets.all(4.r),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.keyboard_arrow_down_rounded,
//                       color: Colors.white,
//                       size: 20.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
