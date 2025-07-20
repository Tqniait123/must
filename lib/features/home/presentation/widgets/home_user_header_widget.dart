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
import 'package:must_invest/core/extensions/widget_extensions.dart';
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
                  context.push(Routes.scanQrcode);
                },
              ),
              6.gap,
              CustomIconButton(
                iconAsset: AppIcons.qrCodeIc,
                color: AppColors.primary,
                onPressed: () {
                  showAllCarsBottomSheet(context, onChooseCar: onChooseCar);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showAllCarsBottomSheet(BuildContext context, {void Function(Car car)? onChooseCar}) async {
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
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocaleKeys.my_cars.tr(), style: context.titleMedium.bold),
                16.gap,
                BlocProvider(
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

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cars.length,
                          separatorBuilder: (context, index) => 12.gap,
                          itemBuilder: (context, index) {
                            final car = cars[index];
                            final isSelected = selectedId == car.id;

                            return CarWidget.selectable(
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
                        );
                      }

                      // Initial state or other states
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                20.gap,
                CustomElevatedButton(
                  height: 50,
                  onPressed:
                      selectedId != null
                          ? () {
                            Navigator.pop(context, selectedId);
                          }
                          : null,
                  title: LocaleKeys.select_car.tr(),
                ).paddingSymmetric(20, 5),
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
