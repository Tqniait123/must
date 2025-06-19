import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/loading/loading_widget.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/home/presentation/widgets/my_points_card.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = true;

  @override
  Widget build(BuildContext context) {
    final parkingList = Parking.getFakeHistoryParkings();

    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-100, -200),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),

        upperContent: UserHomeHeaderWidget(searchController: _searchController),
        backgroundPatternAssetPath: AppImages.homePattern,

        children: [
          30.gap,
          MyPointsCardMinimal(),
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
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.35, // Set a fixed height for the ListView
            child: BlocProvider(
              create:
                  (BuildContext context) =>
                      ExploreCubit(sl())
                        ..getAllParkings(filter: FilterModel(byUserCity: true)),
              child: BlocBuilder<ExploreCubit, ExploreState>(
                builder: (BuildContext context, ExploreState state) {
                  if (state is ParkingsLoading) {
                    return LoadingWidget();
                  } else if (state is ParkingsSuccess) {
                    return ListView.separated(
                      physics:
                          const BouncingScrollPhysics(), // Add physics for better scrolling
                      shrinkWrap:
                          false, // Don't use shrinkWrap as we've set a height
                      padding:
                          EdgeInsets
                              .zero, // Remove padding to avoid extra space
                      itemCount: state.parkings.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return ParkingCard(parking: state.parkings[index]);
                      },
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          30.gap, // Add some padding at the bottom
        ],
      ),
    );
  }
}
