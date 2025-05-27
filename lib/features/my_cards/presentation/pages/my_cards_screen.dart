import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(
                  LocaleKeys.my_cards.tr(),
                  style: context.titleLarge.copyWith(),
                ),
                NotificationsButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                ),
              ],
            ),
            39.gap,
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          LocaleKeys.instapay.tr(),
                          style: context.textTheme.bodyMedium!.s16.regular
                              .copyWith(color: AppColors.primary),
                        ),
                        const Spacer(),
                        Radio(
                          value: true,
                          groupValue: true,
                          onChanged: (value) {},
                        ),
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
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      8.gap,
                      Text(
                        LocaleKeys.add_new_card.tr(),
                        style: context.textTheme.bodyMedium!.s14.regular
                            .copyWith(
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Row(
                children: [
                  Text(
                    LocaleKeys.vodafone_cash.tr(),
                    style: context.textTheme.bodyMedium!.s16.regular.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
            24.gap,
            Row(
              children: [
                Text(
                  LocaleKeys.send_receipt_to_your_email.tr(),
                  style: context.textTheme.bodyMedium!.s12.regular.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Switch.adaptive(value: false, onChanged: (value) {}),
              ],
            ),
          ],
        ).paddingHorizontal(24),
      ),
    );
  }
}
