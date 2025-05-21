// import 'package:easy_localization/easy_localization.dart';
// import 'package:sportify/core/translations/locale_keys.g.dart';

// extension DateTimeTimeDifferenceExtension on DateTime {
//   String formatTimeDifference() {

//     final now = DateTime.now();
//     final difference = now.difference(this);

//     if (difference.inDays >= 365) {
//       final years = (difference.inDays / 365).floor();
//       return '$years ${years == 1 ? LocaleKeys.year.tr() : LocaleKeys.years.tr()} ${LocaleKeys.ago.tr(gender: years == 1 ? "male" : "female")}';
//     } else if (difference.inDays >= 30) {
//       final months = (difference.inDays / 30).floor();
//       return '$months ${months == 1 ? LocaleKeys.month.tr() : LocaleKeys.months.tr()} ${LocaleKeys.ago.tr(gender: months == 1 ? "male" : "female")}';
//     } else if (difference.inDays >= 7) {
//       final weeks = (difference.inDays / 7).floor();
//       return '$weeks ${weeks == 1 ? LocaleKeys.week.tr() : LocaleKeys.weeks.tr()} ${LocaleKeys.ago.tr(gender: weeks == 1 ? "male" : "female")}';
//     } else if (difference.inHours >= 24) {
//       final days = difference.inDays;
//       return '$days ${days == 1 ? LocaleKeys.day.tr() : LocaleKeys.days.tr()} ${LocaleKeys.ago.tr(gender: days == 1 ? "male" : "female")}';
//     } else if (difference.inHours >= 1) {
//       final hours = difference.inHours;
//       return '$hours ${hours == 1 ? LocaleKeys.hour.tr() : LocaleKeys.hours.tr()} ${LocaleKeys.ago.tr(gender: hours == 1 ? "male" : "female")}';
//     } else if (difference.inMinutes >= 1) {
//       final minutes = difference.inMinutes;
//       return '$minutes ${minutes == 1 ? LocaleKeys.minute.tr() : LocaleKeys.minutes.tr()} ${LocaleKeys.ago.tr(gender: minutes == 1 ? "male" : "female")}';
//     } else {
//       return LocaleKeys.just_now.tr();
//     }
//   }
// }

// //The Same but in clean code
// import 'package:easy_localization/easy_localization.dart';
// import 'package:sportify/core/translations/locale_keys.g.dart';

// extension DateTimeTimeDifferenceExtension on DateTime {
//   String formatTimeDifference() {
//     final now = DateTime.now();
//     final difference = now.difference(this);

//     if (difference.inDays >= 365) {
//       return _formatTimeUnit(difference.inDays ~/ 365, LocaleKeys.year);
//     } else if (difference.inDays >= 30) {
//       return _formatTimeUnit(difference.inDays ~/ 30, LocaleKeys.month);
//     } else if (difference.inDays >= 7) {
//       return _formatTimeUnit(difference.inDays ~/ 7, LocaleKeys.week);
//     } else if (difference.inHours >= 24) {
//       return _formatTimeUnit(difference.inDays, LocaleKeys.day);
//     } else if (difference.inHours >= 1) {
//       return _formatTimeUnit(difference.inHours, LocaleKeys.hour);
//     } else if (difference.inMinutes >= 1) {
//       return _formatTimeUnit(difference.inMinutes, LocaleKeys.minute);
//     } else {
//       return LocaleKeys.just_now.tr();
//     }
//   }

//   String _formatTimeUnit(int value, String key) {
//     return '$value ${value == 1 ? key.tr() : '${key}s'.tr()} ${LocaleKeys.ago.tr(gender: value == 1 ? "male" : "female")}';
//   }
// }
