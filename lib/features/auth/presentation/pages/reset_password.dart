import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(
                    LocaleKeys.reset_password.tr(),
                    style: context.titleLarge.copyWith(),
                  ),
                  51.gap,
                ],
              ),
              46.gap,
              Text(
                LocaleKeys.new_password.tr(),
                style: context.bodyMedium.copyWith(color: AppColors.primary),
              ),
              Text(
                LocaleKeys.enter_the_new_password.tr(),
                style: context.bodyMedium.regular.s14.copyWith(
                  color: AppColors.grey60,
                ),
              ),
              // 48.gap,
              48.gap,
              Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            margin: 0,
                            controller: TextEditingController(),
                            hint: LocaleKeys.password.tr(),
                            title: LocaleKeys.password.tr(),
                          ),
                          16.gap,
                          CustomTextFormField(
                            margin: 0,
                            controller: TextEditingController(),
                            hint: LocaleKeys.password_confirmation.tr(),
                            title: LocaleKeys.password_confirmation.tr(),
                          ),
                          78.gap,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingHorizontal(24),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomElevatedButton(
            title: LocaleKeys.reset_password.tr(),
            onPressed: () {
              context.go(Routes.login);
            },
          ).paddingAll(32),
        ],
      ),
    );
  }
}
