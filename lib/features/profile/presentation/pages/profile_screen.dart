import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/constants.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
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
                Text(
                  LocaleKeys.profile.tr(),
                  style: context.titleLarge.copyWith(color: AppColors.white),
                ),
                NotificationsButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                ),
              ],
            ),
            30.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 43,
                      backgroundImage: NetworkImage(
                        Constants.placeholderProfileImage,
                      ),
                    ),
                    24.gap,
                    Column(
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
                  ],
                ),
                CustomIconButton(
                  color: Color(0xff6468AC),
                  iconAsset: AppIcons.logout,
                  onPressed: () {},
                ).flippedForLocale(context),
              ],
            ),
          ],
        ),

        children: [
          30.gap,
          ProfileItemWidget(
            title: LocaleKeys.profile.tr(),
            iconPath: AppIcons.profileIc,
            onPressed: () {
              context.push(Routes.editProfile);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.my_cars.tr(),
            iconPath: AppIcons.outlinedCarIc,
            onPressed: () {
              context.push(Routes.myCars);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.face_id.tr(),
            iconPath: AppIcons.faceIdIc,
            trailing: Switch.adaptive(value: true, onChanged: (value) {}),
          ),
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
            onPressed: () {},
          ),
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
            onPressed: () {},
          ),
          ProfileItemWidget(
            title: LocaleKeys.settings.tr(),
            iconPath: AppIcons.settingsIc,
            onPressed: () {},
          ),
          20.gap,
          CustomElevatedButton(
            icon: AppIcons.supportIc,
            onPressed: () {},
            title: LocaleKeys.how_can_we_help_you.tr(),
          ),
        ],
      ),
    );
  }
}
