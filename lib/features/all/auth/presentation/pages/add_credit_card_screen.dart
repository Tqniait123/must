// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:must_invest/core/extensions/context_extensions.dart';
// import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
// import 'package:must_invest/core/extensions/num_extension.dart';
// import 'package:must_invest/core/extensions/string_to_icon.dart';
// import 'package:must_invest/core/extensions/text_style_extension.dart';
// import 'package:must_invest/core/extensions/theme_extension.dart';
// import 'package:must_invest/core/extensions/widget_extensions.dart';
// import 'package:must_invest/core/functions/show_congratulation_bottom_sheet.dart';
// import 'package:must_invest/core/services/di.dart';
// import 'package:must_invest/core/static/icons.dart';
// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/translations/locale_keys.g.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
// import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
// import 'package:must_invest/features/auth/presentation/cubit/subscribe_plan_cubit.dart';
// import 'package:must_invest/features/auth/presentation/widgets/credit_card_widget.dart';

// class AddCreditCardScreen extends StatefulWidget {
//   final int planId;
//   const AddCreditCardScreen({super.key, required this.planId});

//   @override
//   State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
// }

// class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
//   final TextEditingController cardNumberController = TextEditingController();
//   final TextEditingController cardHolderController = TextEditingController();
//   final TextEditingController expiryDateController = TextEditingController();
//   final TextEditingController cvvDateController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     // Listen to changes and rebuild the UI
//     cardNumberController.addListener(() => setState(() {}));
//     cardHolderController.addListener(() => setState(() {}));
//     expiryDateController.addListener(() {
//       setState(() {});
//       _formatExpiryDate();
//     });
//     cvvDateController.addListener(() => setState(() {}));
//   }

//   void _formatExpiryDate() {
//     String text = expiryDateController.text.replaceAll(RegExp(r'[^0-9]'), '');
//     if (text.length > 4) {
//       text = text.substring(0, 4);
//     }

//     String formattedText;
//     if (text.length >= 2) {
//       formattedText = '${text.substring(0, 2)}/${text.substring(2)}';
//     } else {
//       formattedText = text;
//     }

//     if (expiryDateController.text != formattedText) {
//       expiryDateController.value = TextEditingValue(
//         text: formattedText,
//         selection: TextSelection.collapsed(offset: formattedText.length),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     cardNumberController.dispose();
//     cardHolderController.dispose();
//     cvvDateController.dispose();
//     super.dispose();
//   }

//   String formatCardNumber(String number) {
//     if (number.length > 4) {
//       return "${number.substring(0, 4)} **** **** ${number.length >= 16 ? number.substring(12) : "****"}";
//     }
//     return number;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         clipBehavior: Clip.none,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 PositionedDirectional(
//                   bottom: -72,
//                   start: 0,
//                   child: Hero(
//                     tag: 'pattern2',
//                     child: AppIcons.curve.svg().flippedForLocale(context),
//                   ),
//                 ),
//                 Container(
//                   width: context.width,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadiusDirectional.only(
//                       bottomEnd: Radius.circular(100),
//                     ),
//                     color: AppColors.backgroundColor,
//                   ),
//                   child: Stack(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 60,
//                         ),
//                         child: Hero(
//                           tag: 'text',
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CustomBackButton(),
//                               20.gap,
//                               Text(
//                                 LocaleKeys.add_credit_card.tr(),
//                                 style: context.bodyMedium.s24.bold.copyWith(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               // Text(
//                               //   LocaleKeys.payment_method_description.tr(),
//                               //   style: context.bodyMedium.s14.light.copyWith(
//                               //     color: Colors.white,
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // PositionedDirectional(
//                 //   top: 48,
//                 //   end: 24,
//                 //   child: CustomLanguageDropDownButton(
//                 //     initialLanguage: context.locale.languageCode,
//                 //     isBordered: true,
//                 //     borderColor: AppColors.white,
//                 //     onChanged: (String value) {},
//                 //   ),
//                 // ),
//               ],
//             ),
//             16.gap,
//             Hero(
//               tag: "form",
//               child: Material(
//                 color: Colors.transparent,
//                 child: Stack(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 17),
//                       child: Opacity(
//                         opacity: 0.5,
//                         child: Container(
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(40),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 17),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 37,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(40),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {},
//                                 child: CreditCardWidget(
//                                   cardNumber: formatCardNumber(
//                                     cardNumberController.text,
//                                   ),
//                                   cardHolder: cardHolderController.text,
//                                   expiryDate: expiryDateController.text,
//                                   cvv: cvvDateController.text,
//                                 ),
//                               ),
//                               40.gap,
//                               // CustomTextFormField(
//                               //   controller: cardNumberController,
//                               //   margin: 0,
//                               //   title: LocaleKeys.card_number.tr(),
//                               //   hint: LocaleKeys.card_number_hint.tr(),
//                               // ),
//                               // 16.gap,
//                               // CustomTextFormField(
//                               //   controller: cardHolderController,
//                               //   margin: 0,
//                               //   title: LocaleKeys.card_holder_name.tr(),
//                               //   hint: LocaleKeys.card_holder_hint.tr(),
//                               // ),
//                               16.gap,
//                               Row(
//                                 children: [
//                                   // Expanded(
//                                   //   child: CustomTextFormField(
//                                   //     controller: expiryDateController,
//                                   //     margin: 0,
//                                   //     title: LocaleKeys.expiry_date.tr(),
//                                   //     hint: LocaleKeys.expiry_date_hint.tr(),
//                                   //   ),
//                                   // ),
//                                   // 16.gap,
//                                   // Expanded(
//                                   //   child: CustomTextFormField(
//                                   //     controller: cvvDateController,
//                                   //     margin: 0,
//                                   //     title: LocaleKeys.cvv.tr(),
//                                   //     hint: LocaleKeys.cvv_hint.tr(),
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                               16.gap,
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 50,
//                                     height: 32,
//                                     child: FittedBox(
//                                       fit: BoxFit.cover,
//                                       child: Switch.adaptive(
//                                         activeColor: AppColors.primary,
//                                         value: true,
//                                         onChanged: (value) {},
//                                       ),
//                                     ),
//                                   ),
//                                   8.gap,
//                                   // Text(
//                                   //   LocaleKeys.set_as_default.tr(),
//                                   //   style: context.bodyMedium.s12.regular,
//                                   // ),
//                                 ],
//                               ),
//                               78.gap,
//                               Column(
//                                 children: [
//                                   BlocProvider(
//                                     create:
//                                         (BuildContext context) =>
//                                             SubscribePlanCubit(sl()),
//                                     child: BlocConsumer<
//                                       SubscribePlanCubit,
//                                       SubscribePlanState
//                                     >(
//                                       listener: (
//                                         BuildContext context,
//                                         SubscribePlanState state,
//                                       ) {
//                                         if (state is SubscribePlanSuccess) {
//                                           // showCongratulationsSheet(
//                                           //   context: context,
//                                           //   message:
//                                           //       LocaleKeys
//                                           //           .payment_success_message
//                                           //           .tr(),
//                                           //   onConfirm: () {
//                                           //     // context.push(Routes.pickLocation);
//                                           //   },
//                                           // );
//                                         }
//                                       },
//                                       builder:
//                                           (
//                                             BuildContext context,
//                                             SubscribePlanState state,
//                                           ) => CustomElevatedButton(
//                                             loading:
//                                                 state is SubscribePlanLoading,
//                                             isDisabled: false,
//                                             title: LocaleKeys.continue_btn.tr(),
//                                             onPressed: () {
//                                               SubscribePlanCubit.get(
//                                                 context,
//                                               ).subscribePlan(widget.planId);
//                                               // showCongratulationsSheet(
//                                               //     context: context,
//                                               //     message: LocaleKeys
//                                               //         .payment_success_message
//                                               //         .tr(),
//                                               //     onConfirm: () {
//                                               //       context.push(
//                                               //           Routes.pickLocation);
//                                               //     });
//                                             },
//                                           ).paddingHorizontal(12),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
