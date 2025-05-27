import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/constants.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/all/auth/data/models/user.dart';
import 'package:must_invest/features/user/home/presentation/widgets/home_user_header_widget.dart';

class HomeParkingMan extends StatefulWidget {
  const HomeParkingMan({super.key});

  @override
  State<HomeParkingMan> createState() => _HomeParkingManState();
}

class _HomeParkingManState extends State<HomeParkingMan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usersList = Constants.getRealisticFakeUsers();

    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-100, -200),
        spacerHeight: 35,
        topPadding: 70,
        scrollType: ScrollType.nonScrollable,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),

        upperContent: UserHomeHeaderWidget(searchController: _searchController),
        backgroundPatternAssetPath: AppImages.homePattern,
        scrollPhysics: const NeverScrollableScrollPhysics(),

        children: [
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
              ).withPressEffect(
                onTap: () {
                  // Handle "See More" button tap
                  context.push(Routes.explore);
                },
              ),
            ],
          ),
          16.gap, // Add a gap before the ListView
          Expanded(
            child: ListView.separated(
              physics:
                  const BouncingScrollPhysics(), // Add physics for better scrolling
              shrinkWrap: false, // Don't use shrinkWrap as we've set a height
              padding: EdgeInsets.zero, // Remove padding to avoid extra space
              itemCount: usersList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return UserWidget(user: usersList[index]);
              },
            ),
          ),
          30.gap, // Add some padding at the bottom
        ],
      ),
    );
  }
}

class UserWidget extends StatelessWidget {
  final User user;

  const UserWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xffF4F4FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image:
                        user.photo != null
                            ? NetworkImage(user.photo!)
                            : NetworkImage(Constants.placeholderProfileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   user.address ?? '',
                    //   style: co
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // السيارات
          if (user.cars.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "السيارات:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...user.cars.map(
                  (car) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, size: 20),
                        const SizedBox(width: 8),
                        Text("${car.model} - ${car.plateNumber}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
