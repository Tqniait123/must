import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "notifications",
      child: CustomIconButton(
        color: AppColors.white,
        iconAsset: AppIcons.notificationsIc,
        iconColor: AppColors.black,
        isBordered: true,
        onPressed: () {
          context.push(Routes.notifications);
        },
      ),
    );
  }
}
