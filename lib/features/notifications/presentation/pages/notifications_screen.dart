import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/features/notifications/presentation/cubit/notifications_cubit.dart';
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
                Text(LocaleKeys.notifications.tr(), style: context.titleLarge.copyWith()),
                const SizedBox(width: 51, height: 51),
              ],
            ),
            64.gap,
            Expanded(
              child: BlocProvider(
                create: (context) => NotificationsCubit(sl())..getNotifications(),
                child: BlocConsumer<NotificationsCubit, NotificationsState>(
                  listener: (BuildContext context, NotificationsState state) {
                    // Handle side effects here if needed
                    if (state is NotificationsError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (BuildContext context, NotificationsState state) {
                    return _buildContent(state);
                  },
                ),
              ),
            ),
          ],
        ).paddingHorizontal(24),
      ),
    );
  }

  Widget _buildContent(NotificationsState state) {
    switch (state) {
      case NotificationsInitial():
      case NotificationsLoading():
        return const Center(child: CircularProgressIndicator());

      case NotificationsSuccess():
        if (state.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                16.gap,
                Text(
                  LocaleKeys.no_notification_yet.tr(), // Add this key to your translations
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: state.notifications.length,
          itemBuilder: (context, index) {
            return NotificationWidget(notification: state.notifications[index]);
          },
        );

      case NotificationsError():
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              16.gap,
              Text(state.message, style: TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              16.gap,
              // ElevatedButton(
              //   onPressed: () {
              //     // Retry loading notifications
              //     NotificationsCubit.get(context).getNotifications();
              //   },
              //   child: Text(LocaleKeys.retry.tr()), // Add this key to your translations
              // ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
