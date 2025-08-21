import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/presentation/cubit/cars_cubit.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';

class UserHomeHeaderWidget extends StatelessWidget {
  const UserHomeHeaderWidget({super.key, required TextEditingController searchController, this.onChooseCar})
    : _searchController = searchController;

  final TextEditingController _searchController;
  final void Function(Car car)? onChooseCar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIconButton(
                    iconAsset: AppIcons.menuIc,
                    iconColor: AppColors.white,
                    color: Color(0xff6468AC),
                    onPressed: () {
                      context.push(Routes.profile);
                    },
                  ),
                  15.gap,
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.hola_name.tr(namedArgs: {"name": context.user.name}),
                          style: context.bodyMedium.s24.bold.copyWith(color: AppColors.white),
                        ).withPressEffect(
                          onTap: () {
                            context.push(Routes.profile);
                          },
                        ),
                        10.gap,
                        Text(
                          LocaleKeys.find_an_easy_parking_spot.tr(),
                          style: context.bodyMedium.s16.regular.copyWith(color: AppColors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            15.gap,
            Row(children: [NotificationsButton()]),
          ],
        ),
        40.gap,
        CustomTextFormField(
          controller: _searchController,
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
                onPressed: () {
                  context.checkVerifiedAndGuestOrDo(
                    () => showAllCarsBottomSheet(
                      context,
                      title: LocaleKeys.select_car.tr(), // You might need to add this translation key
                      onChooseCar: (car) {
                        // Navigate to scan QR code screen with selected car
                        context.push(Routes.scanQrcode, extra: car);
                      },
                    ),
                  );
                  // Show car selection for camera scan
                },
              ),
              6.gap,
              CustomIconButton(
                iconAsset: AppIcons.qrCodeIc,
                color: AppColors.primary,
                onPressed: () {
                  context.checkVerifiedAndGuestOrDo(
                    () => showAllCarsBottomSheet(context, title: LocaleKeys.my_cars.tr(), onChooseCar: onChooseCar),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showAllCarsBottomSheet(BuildContext context, {void Function(Car car)? onChooseCar, String? title}) async {
  Car? selectedCar;
  final selectedCarId = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      String? selectedId;

      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7, // Start at 70% of screen height
            minChildSize: 0.5, // Minimum 50% of screen height
            maxChildSize: 0.9, // Maximum 90% of screen height
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),

                    // Fixed header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: Text(title ?? LocaleKeys.my_cars.tr(), style: context.titleMedium.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Scrollable content (takes remaining space except button area)
                    Expanded(
                      child: BlocProvider(
                        create: (BuildContext context) => CarCubit(sl())..getMyCars(),
                        child: BlocBuilder<CarCubit, CarState>(
                          builder: (context, state) {
                            if (state is CarsLoading) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
                              );
                            }

                            if (state is CarsError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        state.message,
                                        style: context.bodyMedium.copyWith(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                      8.gap,
                                      TextButton(
                                        onPressed: () {
                                          CarCubit.get(context).getMyCars();
                                        },
                                        child: Text(LocaleKeys.retry.tr()),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (state is CarsSuccess) {
                              final cars = state.cars;

                              if (cars.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      LocaleKeys.no_cars_found.tr(),
                                      style: context.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }

                              // Cars grid with proper scrolling
                              return SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 20, // Add bottom padding to prevent content from being hidden behind button
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 2 items per row
                                    childAspectRatio: 0.90, // Adjust height ratio (width/height)
                                    crossAxisSpacing: 12, // Horizontal spacing between items
                                    mainAxisSpacing: 12, // Vertical spacing between items
                                  ),
                                  itemCount: cars.length,
                                  itemBuilder: (context, index) {
                                    final car = cars[index];
                                    final isSelected = selectedId == car.id;

                                    return CarWidget.gridDesign(
                                      car: car,
                                      isSelect: isSelected,
                                      onSelectChanged: (value) {
                                        setState(() {
                                          selectedId = value ?? false ? car.id : null;
                                          selectedCar = value ?? false ? car : null;
                                        });
                                      },
                                    );
                                  },
                                ),
                              );
                            }

                            // Initial state or other states
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),

                    // Fixed button at bottom (outside of scrollable area)
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      decoration: BoxDecoration(
                        color: context.theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
                        ],
                      ),
                      child: SafeArea(
                        top: false, // Only apply safe area to bottom
                        child: CustomElevatedButton(
                          height: 50,
                          onPressed:
                              selectedId != null
                                  ? () {
                                    Navigator.pop(context, selectedId);
                                  }
                                  : null,
                          title: LocaleKeys.select_car.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );

  if (selectedCarId != null && selectedCar != null) {
    if (onChooseCar != null) {
      onChooseCar(selectedCar!);
    } else {
      // Default behavior if no callback is provided
      context.push(Routes.myQrCode, extra: selectedCar);
    }
  }
}

// Alternative simpler version if you prefer fixed height approach
void showAllCarsBottomSheetSimple(BuildContext context, {void Function(Car car)? onChooseCar, String? title}) async {
  Car? selectedCar;
  final selectedCarId = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      String? selectedId;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8, // Fixed 80% height
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: Text(title ?? LocaleKeys.my_cars.tr(), style: context.titleMedium.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scrollable content
                Expanded(
                  child: BlocProvider(
                    create: (BuildContext context) => CarCubit(sl())..getMyCars(),
                    child: BlocBuilder<CarCubit, CarState>(
                      builder: (context, state) {
                        if (state is CarsLoading) {
                          return const Center(
                            child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
                          );
                        }

                        if (state is CarsError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    state.message,
                                    style: context.bodyMedium.copyWith(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  8.gap,
                                  TextButton(
                                    onPressed: () {
                                      CarCubit.get(context).getMyCars();
                                    },
                                    child: Text(LocaleKeys.retry.tr()),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (state is CarsSuccess) {
                          final cars = state.cars;

                          if (cars.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  LocaleKeys.no_cars_found.tr(),
                                  style: context.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Cars list
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: cars.length,
                                  separatorBuilder: (context, index) => 12.gap,
                                  itemBuilder: (context, index) {
                                    final car = cars[index];
                                    final isSelected = selectedId == car.id;

                                    return CarWidget.selectDesign(
                                      car: car,
                                      isSelect: isSelected,
                                      onSelectChanged: (value) {
                                        setState(() {
                                          selectedId = value ?? false ? car.id : null;
                                          selectedCar = value ?? false ? car : null;
                                        });
                                      },
                                    ).withPressEffect(
                                      onTap: () {
                                        setState(() {
                                          selectedId = car.id;
                                          selectedCar = car;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),

                              // Fixed button at bottom
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: context.theme.scaffoldBackgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: CustomElevatedButton(
                                  height: 50,
                                  onPressed:
                                      selectedId != null
                                          ? () {
                                            Navigator.pop(context, selectedId);
                                          }
                                          : null,
                                  title: LocaleKeys.select_car.tr(),
                                ),
                              ),
                            ],
                          );
                        }

                        // Initial state or other states
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (selectedCarId != null && selectedCar != null) {
    if (onChooseCar != null) {
      onChooseCar(selectedCar!);
    } else {
      // Default behavior if no callback is provided
      context.push(Routes.myQrCode, extra: selectedCar);
    }
  }
}
