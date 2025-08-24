import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

void showLogoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,

    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            32.gap,

            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.logout_rounded, size: 40, color: Colors.red),
            ),
            24.gap,

            // Title
            Text(
              LocaleKeys.logout_confirmation_title.tr(),
              style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            12.gap,

            // Description
            Text(
              LocaleKeys.logout_confirmation_message.tr(),
              style: context.bodyMedium.copyWith(color: AppColors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            40.gap,
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomElevatedButton(
                    title: LocaleKeys.logout.tr(),
                    isFilled: true,
                    textColor: AppColors.white,
                    backgroundColor: AppColors.redD7,
                    withShadow: false,
                    isBordered: true,
                    onPressed: () {
                      context.go(Routes.login);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomElevatedButton(
                    title: LocaleKeys.back.tr(),
                    isFilled: false,
                    textColor: AppColors.black,
                    withShadow: false,
                    isBordered: true,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
