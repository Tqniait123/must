import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/congratulation_bototm_sheet.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/toaster.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/home/presentation/cubit/home_cubit.dart';
import 'package:must_invest/features/home/presentation/cubit/home_state.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  void _showMoneyInputBottomSheet(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  20.gap,

                  // Title
                  Text(
                    LocaleKeys.vodafone_cash.tr(),
                    style: context.titleLarge.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  8.gap,

                  Text(
                    LocaleKeys.enter_amount_to_charge.tr(),
                    style: context.textTheme.bodyMedium!.s14.regular.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  24.gap,

                  // Amount input field
                  CustomTextFormField(
                    controller: amountController,
                    hint: LocaleKeys.enter_amount_egp.tr(),
                    isBordered: true,
                    backgroundColor: Color(0xffF4F4FA),
                    hintColor: AppColors.primary.withValues(alpha: 0.5),
                    keyboardType: TextInputType.number,
                  ),
                  24.gap,

                  // Predefined amount buttons
                  Text(
                    LocaleKeys.quick_amounts.tr(),
                    style: context.textTheme.bodyMedium!.s14.regular.copyWith(color: AppColors.primary),
                  ),
                  12.gap,

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['100', '500', '1000', '2000', '5000'].map((amount) {
                          return InkWell(
                            onTap: () {
                              amountController.text = amount;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$amount ${LocaleKeys.egp.tr()}',
                                style: context.textTheme.bodyMedium!.s12.regular.copyWith(color: AppColors.primary),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  32.gap,

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          child: Text(
                            LocaleKeys.cancel.tr(),
                            style: context.textTheme.bodyMedium!.s16.medium.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      16.gap,
                      Expanded(
                        child: BlocProvider(
                          create: (BuildContext context) => HomeCubit(sl()),
                          child: BlocConsumer<HomeCubit, HomeState>(
                            listener: (BuildContext context, HomeState state) async {
                              if (state is HomeLoading) {
                                Toaster.showLoading();
                              }
                              // Handle side effects here if needed
                              if (state is HomeError) {
                                Toaster.closeLoading();
                                showErrorToast(context, state.message);
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                              }
                              if (state is HomeSuccess) {
                                Toaster.closeLoading();

                                // Navigate to payment webview
                                final isSuccess = await context.push(Routes.payment, extra: state.paymentUrl);

                                if (isSuccess == true) {
                                  // Check if the context is still valid
                                  if (!context.mounted) return;

                                  final newPointsAdded = context.convertMoneyToPoints(
                                    double.parse(amountController.text.trim()),
                                  );
                                  final allUserPoints = context.user.points + newPointsAdded;

                                  context.updateUserPoints(context.user.points + newPointsAdded);

                                  // Check again before showing bottom sheet
                                  if (!context.mounted) return;

                                  CongratulationsBottomSheet.show(
                                    context,
                                    message: LocaleKeys.points_added_successfully.tr(
                                      namedArgs: {
                                        'newPoints': newPointsAdded.toString(),
                                        'allPoints': allUserPoints.toString(),
                                      },
                                    ),
                                    points: newPointsAdded,
                                    onContinue: () {
                                      if (context.mounted) {
                                        context.go(Routes.homeUser);
                                      }
                                    },
                                  );
                                } else {
                                  if (context.mounted) {
                                    showErrorToast(context, LocaleKeys.payment_error.tr());
                                  }
                                }
                              }
                            },
                            builder:
                                (BuildContext context, HomeState state) => CustomElevatedButton(
                                  loading: state is HomeLoading,
                                  onPressed: () {
                                    final amount = amountController.text.trim();
                                    if (amount.isNotEmpty) {
                                      HomeCubit.get(context).chargePoints(amount);
                                    }
                                  },

                                  title: LocaleKeys.charge.tr(),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4FA),
      body: SafeArea(
        child: BlocProvider(
          create: (BuildContext context) => HomeCubit(sl()),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(LocaleKeys.my_cards.tr(), style: context.titleLarge.copyWith()),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
              39.gap,
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.instapay.tr(),
                            style: context.textTheme.bodyMedium!.s16.regular.copyWith(color: AppColors.primary),
                          ),
                          const Spacer(),
                          Radio(value: true, groupValue: true, onChanged: (value) {}),
                        ],
                      ),
                    ),
                    16.gap,
                    CustomTextFormField(
                      hint: LocaleKeys.your_number_or_email.tr(),
                      isBordered: false,
                      backgroundColor: Color(0xffF4F4FA),
                      hintColor: AppColors.primary,
                      controller: TextEditingController(),
                    ),
                    16.gap,
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                        8.gap,
                        Text(
                          LocaleKeys.add_new_card.tr(),
                          style: context.textTheme.bodyMedium!.s14.regular.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              24.gap,
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.vodafone_cash.tr(),
                      style: context.textTheme.bodyMedium!.s16.regular.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                  ],
                ),
              ).withPressEffect(
                onTap: () {
                  _showMoneyInputBottomSheet(context);
                },
              ),
              24.gap,
              Row(
                children: [
                  Text(
                    LocaleKeys.send_receipt_to_your_email.tr(),
                    style: context.textTheme.bodyMedium!.s12.regular.copyWith(color: AppColors.primary),
                  ),
                  const Spacer(),
                  Switch.adaptive(value: false, onChanged: (value) {}),
                ],
              ),
            ],
          ).paddingHorizontal(24),
        ),
      ),
    );
  }
}
