import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

void showLogoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,

    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppIcons.signoutIllu.svg(),

            // Text(
            //   LocaleKeys.sign_out_confirm.tr(), // "Login Required"
            //   style: AppStyles.bold16black.copyWith(fontSize: 16.r),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 12),
            // Text(
            //   LocaleKeys.please_dont_leave
            //       .tr(), // "To enjoy full app features, please log in or create an account."
            //   style: context.theme.textTheme.bodyMedium!.copyWith(
            //     color: Colors.black54,
            //     height: 1.5,
            //     fontSize: 10.r,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
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
