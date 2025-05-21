import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';

enum AccountType { user, securityMan }

class AccountTypeSelectorWidget extends StatefulWidget {
  final void Function(AccountType type)? onSelectType;
  const AccountTypeSelectorWidget({super.key, this.onSelectType});

  @override
  State<AccountTypeSelectorWidget> createState() =>
      _AccountTypeSelectorWidgetState();
}

class _AccountTypeSelectorWidgetState extends State<AccountTypeSelectorWidget> {
  AccountType? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OptionWidget(
          option: LocaleKeys.user.tr(),
          isSelected: selectedOption == AccountType.user,
          assetPath: AppImages.parents,
          selectedOption: AccountType.user,
          onTap: (option) {
            setState(() {
              selectedOption = option;
              widget.onSelectType?.call(option);
            });
          },
        ),
        16.gap,
        OptionWidget(
          option: LocaleKeys.security_man.tr(),
          isSelected: selectedOption == AccountType.securityMan,
          assetPath: AppImages.teen,
          selectedOption: AccountType.securityMan,
          onTap: (option) {
            setState(() {
              selectedOption = option;
              widget.onSelectType?.call(option);
            });
          },
        ),
      ],
    );
  }
}

class OptionWidget extends StatelessWidget {
  final String option;
  final bool isSelected;
  final String assetPath;
  final AccountType selectedOption;
  final void Function(AccountType option)? onTap;
  const OptionWidget({
    super.key,
    required this.option,
    required this.isSelected,
    required this.assetPath,
    required this.selectedOption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(selectedOption);
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.primary.withAlpha(50),
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(milliseconds: 200),
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).withPressEffect(
      onTap: () {
        if (onTap != null) {
          onTap!(selectedOption);
        }
      },
    );
  }
}
