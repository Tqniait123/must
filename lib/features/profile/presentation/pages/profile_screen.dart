import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/logout_sheet.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/profile/presentation/widgets/profile_item_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-150, -400),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),

        upperContent: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(LocaleKeys.profile.tr(), style: context.titleLarge.copyWith(color: AppColors.white)),
                NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
              ],
            ),
            30.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (context.isLoggedIn) ...[
                        if (context.user.image != null && context.user.image!.isNotEmpty)
                          CircleAvatar(radius: 43, backgroundImage: NetworkImage(context.user.image ?? '')),
                        24.gap,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.welcome.tr(),
                                style: context.bodyMedium.copyWith(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              8.gap,
                              Text(
                                context.user.name,
                                style: context.titleLarge.copyWith(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        children: [
          30.gap,
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.profile.tr(),
              iconPath: AppIcons.profileIc,
              onPressed: () {
                context.push(Routes.editProfile);
              },
            ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.my_cars.tr(),
              iconPath: AppIcons.outlinedCarIc,
              onPressed: () {
                context.push(Routes.myCars);
              },
            ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.offers.tr(),
              iconPath: AppIcons.offersIc,
              onPressed: () {
                context.push(Routes.offers);
              },
            ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.my_cards.tr(),
              iconPath: AppIcons.cardIc,
              onPressed: () {
                context.push(Routes.myCards);
              },
            ),
          ProfileItemWidget(
            title: LocaleKeys.terms_and_conditions.tr(),
            iconPath: AppIcons.termsIc,
            onPressed: () {
              context.push(Routes.termsAndConditions);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.privacy_policy.tr(),
            iconPath: AppIcons.privacyPolicyIc,
            onPressed: () {
              context.push(Routes.privacyPolicy);
            },
          ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.history.tr(),
              iconPath: AppIcons.historyIc,
              onPressed: () {
                context.push(Routes.history);
              },
            ),
          ProfileItemWidget(
            title: LocaleKeys.faq.tr(),
            iconPath: AppIcons.faqIc,
            onPressed: () {
              context.push(Routes.faq);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.about_us.tr(),
            iconPath: AppIcons.aboutUsIc,
            onPressed: () {
              context.push(Routes.aboutUs);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.settings.tr(),
            iconPath: AppIcons.settingsIc,
            onPressed: () {
              context.push(Routes.settings);
            },
          ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.delete_account_confirmation_title.tr(),
              iconPath: AppIcons.deleteIc,
              color: Colors.red,
              onPressed: () {
                showDeleteAccountBottomSheet(context);
              },
            ),
          if (context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.logout.tr(),
              iconPath: AppIcons.logout,
              color: Colors.red,
              onPressed: () {
                showLogoutBottomSheet(context);
              },
            ),
          if (!context.isLoggedIn)
            ProfileItemWidget(
              title: LocaleKeys.login.tr(),
              iconPath: AppIcons.loginIc,
              // color: Colors.red,
              onPressed: () {
                context.push(Routes.login);
              },
            ),
          20.gap,

          // 40.gap,
        ],
      ),
      bottomNavigationBar: CustomElevatedButton(
        icon: AppIcons.supportIc,
        onPressed: () {
          context.push(Routes.contactUs);
        },
        title: LocaleKeys.how_can_we_help_you.tr(),
      ).paddingSymmetric(40, 0).paddingBottom(40),
    );
  }
}
