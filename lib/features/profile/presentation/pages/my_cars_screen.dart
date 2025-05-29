import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/presentation/widgets/add_edit_car_bottom_sheet.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';
import 'package:must_invest/features/profile/presentation/widgets/delete_confirmation_bottom_sheet.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<Car> cars = [
    const Car(id: '1', model: 'Toyota Camry', plateNumber: 'ABC-123'),
    const Car(id: '2', model: 'Honda Civic', plateNumber: 'XYZ-789'),
    const Car(id: '3', model: 'BMW X5', plateNumber: 'DEF-456'),
  ];

  void _addCar(Car car) {
    setState(() {
      cars.add(car);
    });
  }

  void _editCar(String id, Car updatedCar) {
    setState(() {
      final index = cars.indexWhere((car) => car.id == id);
      if (index != -1) {
        cars[index] = updatedCar;
      }
    });
  }

  void _deleteCar(String id) {
    setState(() {
      cars.removeWhere((car) => car.id == id);
    });
  }

  void _showAddEditCarBottomSheet({Car? car}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddEditCarBottomSheet(
            car: car,
            onSave: (newCar) {
              if (car == null) {
                _addCar(newCar);
              } else {
                _editCar(car.id, newCar);
              }
            },
          ),
    );
  }

  void _showDeleteConfirmationBottomSheet(Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DeleteConfirmationBottomSheet(
            car: car,
            onDelete: () => _deleteCar(car.id),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(
                  LocaleKeys.my_cars.tr(),
                  style: context.titleLarge.copyWith(),
                ),
                NotificationsButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                ),
              ],
            ),
            cars.isEmpty
                ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          LocaleKeys.no_cars_added_yet.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          LocaleKeys.add_first_car_hint.tr(),
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
                : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CarWidget.editable(
                          car: cars[index],
                          onEdit:
                              () =>
                                  _showAddEditCarBottomSheet(car: cars[index]),
                          onDelete:
                              () => _showDeleteConfirmationBottomSheet(
                                cars[index],
                              ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ).paddingHorizontal(24),
      ),
      bottomNavigationBar: CustomElevatedButton(
        title: LocaleKeys.add_new_car.tr(),
        onPressed: () => _showAddEditCarBottomSheet(),
      ).paddingAll(30),
    );
  }
}
