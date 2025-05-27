import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/presentation/widgets/account_type_selector_widget.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  AccountType? selectedOption;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LogoWidget(
              type: LogoType.svg,
              color: AppColors.primary,
            ).paddingVertical(32),

            Text(
              LocaleKeys.account_type.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            16.gap,
            Text(
              LocaleKeys.complete_profile.tr(),
              style: Theme.of(context).textTheme.bodyMedium!.regular.s16
                  .copyWith(color: AppColors.grey60),
            ),
            48.gap,
            AccountTypeSelectorWidget(
              onSelectType: (option) {
                setState(() {
                  selectedOption = option;
                });
              },
            ),
            Spacer(),
            CustomElevatedButton(
              title: LocaleKeys.continue_now.tr(),
              onPressed: () {
                context.push(Routes.register);
              },
            ),
          ],
        ).paddingHorizontal(24),
      ),
    );
  }
}
