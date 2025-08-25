import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';

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
                      context.userCubit.removeCurrentUser();
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

void showDeleteAccountBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is DeleteAccountSuccess) {
            // Navigate to login screen on successful deletion
            context.userCubit.removeCurrentUser();
            context.go(Routes.login);
            showSuccessToast(context, LocaleKeys.delete_account_confirmation_success.tr());
          } else if (state is DeleteAccountError) {
            showErrorToast(context, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_forever_rounded, size: 40, color: Colors.red),
                ),
                24.gap,

                // Title
                Text(
                  LocaleKeys.delete_account_confirmation_title.tr(),
                  style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
                12.gap,

                // Description
                Text(
                  LocaleKeys.delete_account_confirmation_message.tr(),
                  style: context.bodyMedium.copyWith(color: AppColors.grey, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                40.gap,

                // Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomElevatedButton(
                        loading: state is DeleteAccountLoading,
                        title: LocaleKeys.delete_account_confirmation_ok.tr(),
                        isFilled: true,
                        textColor: AppColors.white,
                        backgroundColor: AppColors.redD7,
                        withShadow: false,
                        isBordered: true,
                        onPressed: () {
                          // Trigger delete account action via AuthCubit
                          AuthCubit.get(context).deleteAccount();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        title: LocaleKeys.delete_account_confirmation_cancel.tr(),
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
    },
  );
}
