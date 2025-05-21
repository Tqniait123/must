import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/user/home/data/models/parking_model.dart';
import 'package:must_invest/features/user/home/presentation/widgets/parking_widget.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = true;

  @override
  Widget build(BuildContext context) {
    final parkingList = Parking.getFakeArabicParkingList();

    return Scaffold(
      body: Stack(
        children: [
          // Background container with primary color and pattern
          Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(color: AppColors.primary),
            child: Stack(
              children: [
                Positioned(
                  left: -0,
                  top: -700,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.3,
                    child: AppIcons.homePattern.svg(
                      width: MediaQuery.sizeOf(context).width * 2,
                      height: MediaQuery.sizeOf(context).height * 2,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Logo positioned in the visible area above the bottom sheet
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.10,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                LocaleKeys.hola_name.tr(
                                  namedArgs: {"name": context.user.name},
                                ),
                                style: context.bodyMedium.s24.bold.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              10.gap,
                              Text(
                                LocaleKeys.find_an_easy_parking_spot.tr(),
                                style: context.bodyMedium.s16.regular.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          CustomIconButton(
                            iconAsset: AppIcons.notificationsIc,
                            color: Color(0xff6468AC),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      40.gap,
                      CustomTextFormField(
                        controller: _emailController,
                        backgroundColor: Color(0xff6468AC),
                        isBordered: false,
                        margin: 0,
                        prefixIC: AppIcons.searchIc.icon(),
                        hint: LocaleKeys.search.tr(),
                        suffixIC: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconButton(
                              iconAsset: AppIcons.cameraIc,
                              color: AppColors.primary,
                              onPressed: () {},
                            ),
                            6.gap,
                            CustomIconButton(
                              iconAsset: AppIcons.qrCodeIc,
                              color: AppColors.primary,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).paddingHorizontal(20),
                ),
              ],
            ),
          ),

          // Bottom sheet with form
          DraggableScrollableSheet(
            initialChildSize:
                0.65, // Take up 65% of the screen height initially
            minChildSize: 0.65, // Minimum size
            maxChildSize: 0.65, // Maximum size when expanded
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.gap,
                        MyPointsCard(),
                        32.gap,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.nearst_parking_spaces.tr(),
                              style: context.bodyMedium.bold.s16.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            // see more text button
                            Text(
                              LocaleKeys.see_more.tr(),
                              style: context.bodyMedium.regular.s14.copyWith(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        16.gap, // Add a gap before the ListView
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.35, // Set a fixed height for the ListView
                          child: ListView.separated(
                            physics:
                                const BouncingScrollPhysics(), // Add physics for better scrolling
                            shrinkWrap:
                                false, // Don't use shrinkWrap as we've set a height
                            padding:
                                EdgeInsets
                                    .zero, // Remove padding to avoid extra space
                            itemCount: parkingList.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return ParkingCard(parking: parkingList[index]);
                            },
                          ),
                        ),
                        30.gap, // Add some padding at the bottom
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
