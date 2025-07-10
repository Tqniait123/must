import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/scrolling_text.dart';
import 'package:must_invest/features/notifications/data/models/notification_model.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              12.gap,
              Expanded(
                child: Row(
                  children: [
                    AppIcons.notificationLabelIc.svg().flippedForLocale(
                      context,
                    ),
                    12.gap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: context.bodyMedium.semiBold.s16,
                          ),
                          4.gap,
                          Row(
                            children: [
                              Expanded(
                                child: ScrollingText(
                                  notification.message,
                                  style: context.bodyMedium.regular.s10
                                      .copyWith(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                ),
                              ),
                              8.gap,
                              Text(
                                notification.createdAt.toString(),
                                style: context.bodyMedium.regular.s10.copyWith(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
        ],
      ),
    );
  }
}
