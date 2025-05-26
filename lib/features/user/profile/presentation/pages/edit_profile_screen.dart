import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/image_picker_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  PlatformFile? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(
                  LocaleKeys.edit_profile.tr(),
                  style: context.titleLarge.copyWith(),
                ),
                CustomIconButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                  iconAsset: AppIcons.qrCodeIc,
                  onPressed: () {},
                ),
              ],
            ),
            40.gap,
            ImagePickerAvatar(
              initialImage: context.user.photo,
              onPick: (image) {},
            ),
            28.gap,
            CustomTextFormField(
              controller: TextEditingController(),
              margin: 0,
              hint: LocaleKeys.full_name.tr(),
              title: LocaleKeys.full_name.tr(),
            ),
            16.gap,
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: TextEditingController(),
                    margin: 0,
                    hint: LocaleKeys.type.tr(),
                    title: LocaleKeys.type.tr(),
                  ),
                ),
                16.gap,
                Expanded(
                  child: CustomTextFormField(
                    controller: TextEditingController(),
                    margin: 0,
                    hint: LocaleKeys.id.tr(),
                    title: LocaleKeys.id.tr(),
                  ),
                ),
              ],
            ),
            16.gap,
            CustomTextFormField(
              controller: TextEditingController(),
              margin: 0,
              hint: LocaleKeys.phone_number.tr(),
              title: LocaleKeys.phone_number.tr(),
            ),
            16.gap,
            CustomTextFormField(
              controller: TextEditingController(),
              margin: 0,
              hint: LocaleKeys.address.tr(),
              title: LocaleKeys.address.tr(),
            ),
            16.gap,
            CustomTextFormField(
              controller: TextEditingController(),
              margin: 0,
              isPassword: true,
              hint: LocaleKeys.password.tr(),
              title: LocaleKeys.password.tr(),
            ),
          ],
        ).paddingHorizontal(24),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: CustomElevatedButton(
              onPressed: () {
                context.pop();
              },
              title: LocaleKeys.cancel.tr(),
              backgroundColor: Color(0xffF4F4FA),
              textColor: AppColors.primary.withValues(alpha: 0.5),
              isBordered: false,
            ),
          ),
          16.gap,
          Expanded(
            child: CustomElevatedButton(
              onPressed: () {
                context.pop();
              },
              title: LocaleKeys.save.tr(),
            ),
          ),
        ],
      ).paddingAll(30),
    );
  }
}
