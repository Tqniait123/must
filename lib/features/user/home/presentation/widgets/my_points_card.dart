import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

class MyPointsCard extends StatelessWidget {
  const MyPointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xff99ABC6).withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 30,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff99ABC6).withValues(alpha: 0.2),
                          spreadRadius: 0,
                          blurRadius: 30,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(AppImages.sun, width: 30, height: 30),
                  ),
                  12.gap,
                  Column(
                    children: [
                      Text(
                        LocaleKeys.my_points.tr(),
                        style: context.bodyMedium.bold.s16,
                      ),
                      4.gap,
                      Text(
                        "12000 ${LocaleKeys.point.tr()}",
                        style: context.bodyMedium.s12.regular.copyWith(
                          color: AppColors.greyAF,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  Icon(
                    Icons.arrow_drop_up_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  4.gap,
                  Text(
                    "+15%",
                    style: context.bodyMedium.s14.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox(height: 44)),
              Expanded(
                child: CustomElevatedButton(
                  height: 44,
                  title: LocaleKeys.add_points.tr(),
                  onPressed: () {
                    context.push(Routes.myCards);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
