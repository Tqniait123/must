import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:must_invest/core/static/constants.dart';
import 'package:must_invest/core/theme/colors.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    //this may be changed in the future
    // useMaterial3: false,
    scaffoldBackgroundColor: AppColors.whiteFD,
    fontFamily: context.locale.languageCode == "en" ? Constants.fontFamilyEN : Constants.fontFamilyAR,
    colorScheme: const ColorScheme.light(primary: AppColors.primary),

    dividerColor: AppColors.grey78,
    dividerTheme: const DividerThemeData(color: AppColors.grey4A, thickness: 0.1),

    //! AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0.0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.green1E),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    ),

    //! Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 4.0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.greyC4),
      selectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w400),
      unselectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.grey78, fontWeight: FontWeight.w400),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey81,
      enableFeedback: false,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),

    //! Buttons Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.white, fontSize: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0.0,
        alignment: Alignment.center,
        enableFeedback: false,
        padding: const EdgeInsets.symmetric(vertical: 19),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        elevation: 0.0,
        alignment: Alignment.center,
        enableFeedback: false,
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, enableFeedback: true, iconSize: 20),
    ),

    checkboxTheme: CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      checkColor: WidgetStateProperty.all(AppColors.primary),
      fillColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.2)),
      shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(),

    //! Text Theme
    textTheme: textTheme(),
  );
}

TextTheme textTheme() {
  return TextTheme(
    //! BODY
    // bodyLarge: TextStyle(
    //   fontSize: 35.sp,
    //   fontStyle: FontStyle.normal,
    //   fontWeight: FontWeight.w900,
    //   color: AppColors.black,
    // ),
    bodyLarge: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    bodyMedium: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 14.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
    //! DISPLAY
    displayLarge: TextStyle(
      fontSize: 20.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),
    displayMedium: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    displaySmall: TextStyle(
      fontSize: 14.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
    //! HEADLINE
    headlineLarge: TextStyle(
      fontSize: 36.3,
      // fontSize: 20.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineSmall: TextStyle(
      fontSize: 14.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
    //! LABEL
    labelLarge: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    labelMedium: TextStyle(
      fontSize: 14.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppColors.primary,
    ),
    labelSmall: TextStyle(
      fontSize: 12.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w300,
      color: AppColors.primary,
    ),
    titleLarge: TextStyle(
      fontSize: 20.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),

    titleMedium: TextStyle(
      fontSize: 16.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    titleSmall: TextStyle(
      fontSize: 14.3,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppColors.grey4A,
    ),
  );
}
