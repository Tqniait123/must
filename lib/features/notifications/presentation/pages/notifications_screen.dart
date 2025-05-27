import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/constants.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/features/notifications/presentation/widgets/notification_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                  LocaleKeys.notifications.tr(),
                  style: context.titleLarge.copyWith(),
                ),
                const SizedBox(width: 51, height: 51),
              ],
            ),
            64.gap,
            Expanded(
              child: ListView.builder(
                itemCount: Constants.fakeNotifications.length,
                itemBuilder: (context, index) {
                  return NotificationWidget(
                    notification: Constants.fakeNotifications[index],
                  );
                },
              ),
            ),
          ],
        ).paddingHorizontal(24),
      ),
    );
  }
}
