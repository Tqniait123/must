import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/user/explore/presentation/widgets/filter_option_widget.dart';
import 'package:must_invest/features/user/home/data/models/parking_model.dart';
import 'package:must_invest/features/user/home/presentation/widgets/parking_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterId = 1;

  final List<Map<String, dynamic>> _filters = [
    {'id': 2, 'title': LocaleKeys.nearst.tr()},
    {'id': 3, 'title': LocaleKeys.most_popular.tr()},
    {'id': 4, 'title': LocaleKeys.most_wanted.tr()},
  ];

  @override
  Widget build(BuildContext context) {
    final parkingList = Parking.getFakeArabicParkingList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: Icon(Icons.my_location_rounded, color: AppColors.white),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(
                    LocaleKeys.explore.tr(),
                    style: context.titleLarge.copyWith(),
                  ),
                  NotificationsButton(
                    color: Color(0xffEAEAF3),
                    iconColor: AppColors.primary,
                  ),
                ],
              ),
              40.gap,
              CustomTextFormField(
                controller: _searchController,
                backgroundColor: Color(0xffEAEAF3),
                hintColor: AppColors.primary.withValues(alpha: 0.4),
                isBordered: false,
                margin: 0,
                prefixIC: AppIcons.searchIc.icon(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                hint: LocaleKeys.search.tr(),
              ),
              20.gap,
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => 10.gap,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterId = filter['id'];
                        });
                      },
                      child: FilterOptionWidget(
                        title: filter['title'],
                        id: filter['id'],
                        isSelected: _selectedFilterId == filter['id'],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics:
                      const BouncingScrollPhysics(), // Add physics for better scrolling
                  shrinkWrap:
                      false, // Don't use shrinkWrap as we've set a height
                  padding:
                      EdgeInsets.zero, // Remove padding to avoid extra space
                  itemCount: parkingList.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return ParkingCard(parking: parkingList[index]);
                  },
                ),
              ),
            ],
          ),
        ).paddingHorizontal(20),
      ),
    );
  }
}
