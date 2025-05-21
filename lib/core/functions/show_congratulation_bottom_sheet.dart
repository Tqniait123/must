// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:must_invest/core/extensions/num_extension.dart';
// import 'package:must_invest/core/extensions/text_style_extension.dart';
// import 'package:must_invest/core/extensions/theme_extension.dart';
// import 'package:must_invest/core/static/app_assets.dart';
// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/translations/locale_keys.g.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

// void showCongratulationsSheet({
//   required BuildContext context,
//   required String message,
//   bool? isDismissible,
//   void Function()? onConfirm,
//   bool showMainButton = true,
//   bool enableDrag = true,
//   String? buttonText,
//   String? textButtonTitle,
//   void Function()? onSecondButtonPressed,
// }) {
//   showModalBottomSheet(
//     backgroundColor: Colors.transparent,
//     // showDragHandle: true,
//     enableDrag: enableDrag,
//     isScrollControlled: true,
//     isDismissible: isDismissible ?? true,
//     context: context,
//     builder:
//         (context) => Wrap(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 52),
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               width: double.infinity,
//               // constraints:
//               //     BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.60),
//               decoration: const BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40),
//                   topRight: Radius.circular(40),
//                   bottomLeft: Radius.circular(40),
//                   bottomRight: Radius.circular(40),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 82),
//                   Image.asset(AppAnimations.congratulationsAnimation),
//                   28.gap,
//                   Text(
//                     LocaleKeys.payment_success.tr(),
//                     textAlign: TextAlign.center,
//                     style: context.textTheme.bodyMedium!.semiBold.s22,
//                   ),
//                   12.gap,
//                   Text(
//                     message,
//                     textAlign: TextAlign.center,
//                     style: context.textTheme.bodyMedium!.regular.s12,
//                   ),
//                   23.gap,
//                   Text(
//                     LocaleKeys.total_payment.tr(),
//                     textAlign: TextAlign.center,
//                     style: context.textTheme.bodyMedium!.regular.s12.copyWith(
//                       color: Colors.grey,
//                     ),
//                   ),
//                   4.gap,
//                   Text(
//                     'SAR 17.99',
//                     textAlign: TextAlign.center,
//                     style: context.textTheme.bodyMedium!.bold.s18,
//                   ),
//                   19.gap,
//                   if (showMainButton == true) ...[
//                     CustomElevatedButton(
//                       title: buttonText ?? LocaleKeys.start_now.tr(),
//                       onPressed: onConfirm,
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                   if (textButtonTitle != null)
//                     TextButton(
//                       onPressed: onSecondButtonPressed,
//                       child: Text(textButtonTitle),
//                     ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//   );
// }
