import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/scrolling_text.dart';
import 'package:must_invest/features/all/notifications/data/models/notification_model.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            12.gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: context.bodyMedium.semiBold.s16,
                  ),
                  4.gap,
                  Row(
                    children: [
                      Expanded(
                        child: ScrollingText(
                          notification.description,
                          style: context.bodyMedium.regular.s14.copyWith(
                            color: AppColors.grey60,
                          ),
                        ),
                      ),
                      8.gap,
                      Text(
                        notification.date,
                        style: context.bodyMedium.regular.s10.copyWith(
                          color: AppColors.grey60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 20.gap,
            // MoneyText(
            //   amount: notification.transactionAmount.toString(),
            //   amountTextSize: 16,
            // ),
          ],
        ),
        20.gap,
        Row(
          children: [
            Expanded(
              child: CustomElevatedButton(
                height: 35,
                heroTag: 'accept-${notification.id}',
                title: LocaleKeys.accept.tr(),
                onPressed: () {},
              ),
            ),
            16.gap,
            Expanded(
              child: CustomElevatedButton(
                height: 35,
                backgroundColor: Color(0xffF5F5F5),
                title: LocaleKeys.ignore.tr(),
                heroTag: 'ignore-${notification.id}',
                withShadow: false,
                textColor: AppColors.black,
                onPressed: () {},
              ),
            ),
          ],
        ),
        20.gap,
        Divider(),
        20.gap,
      ],
    );
  }
}
