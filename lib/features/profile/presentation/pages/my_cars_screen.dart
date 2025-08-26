import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/context_extensions.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/presentation/cubit/cars_cubit.dart';
import 'package:must_invest/features/profile/presentation/widgets/add_edit_car_bottom_sheet.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';
import 'package:must_invest/features/profile/presentation/widgets/delete_confirmation_bottom_sheet.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<Car> displayedCars = [];
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    // Load cars when screen initializes
    CarCubit.get(context).getMyCars();
  }

  void _showAddEditCarBottomSheet({Car? car}) {
    final carCubit = CarCubit.get(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider.value(
            value: carCubit,
            child: AddEditCarBottomSheet(
              car: car,
              onSuccess: () {
                // The cubit handles optimistic updates automatically
                // No need to navigate or refresh anything
              },
            ),
          ),
    );
  }

  void _showDeleteConfirmationBottomSheet(Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteConfirmationBottomSheet(car: car, onDelete: () => _deleteCar(car.id)),
    );
  }

  void _deleteCar(String carId) {
    CarCubit.get(context).deleteCar(carId);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            LocaleKeys.no_cars_added_yet.tr(),
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(LocaleKeys.add_first_car_hint.tr(), style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
          SizedBox(height: 16),
          Text(LocaleKeys.loading_cars.tr(), style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            LocaleKeys.failed_to_load_cars.tr(),
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(message, style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          SizedBox(height: 16),
          CustomElevatedButton(title: LocaleKeys.try_again.tr(), onPressed: () => CarCubit.get(context).getMyCars()),
        ],
      ),
    );
  }

  Widget _buildCarsList(List<Car> cars) {
    return ListView.builder(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: CarWidget.editable(
              key: ValueKey(cars[index].id),
              car: cars[index],
              onEdit: () => _showAddEditCarBottomSheet(car: cars[index]),
              onDelete: () => _showDeleteConfirmationBottomSheet(cars[index]),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    switch (isError) {
      case true:
        showErrorToast(context, message);
        break;
      case false:
        showSuccessToast(context, message);
        break;
    }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: isError ? Colors.red : Colors.green,
    //     behavior: SnackBarBehavior.floating,
    //     margin: EdgeInsets.all(16),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(context.width, kToolbarHeight + 5),
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(),
              Text(LocaleKeys.my_cars.tr(), style: context.titleLarge.copyWith()),
              NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
            ],
          ).withSafeArea().paddingHorizontal(24).paddingBottom(10),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocConsumer<CarCubit, CarState>(
                listener: (context, state) {
                  // Handle success/error messages without affecting the main UI
                  if (state is AddCarSuccess) {
                    _showSnackBar(LocaleKeys.car_added_successfully.tr());
                  } else if (state is AddCarError) {
                    _showSnackBar(state.message, isError: true);
                  } else if (state is UpdateCarSuccess) {
                    _showSnackBar(LocaleKeys.car_updated_successfully.tr());
                  } else if (state is UpdateCarError) {
                    _showSnackBar(state.message, isError: true);
                  } else if (state is DeleteCarSuccess) {
                    _showSnackBar(LocaleKeys.car_deleted_successfully.tr());
                  } else if (state is DeleteCarError) {
                    _showSnackBar(state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  // Handle cars list updates
                  if (state is CarsSuccess) {
                    displayedCars = state.cars;
                    isInitialLoading = false;
                  }

                  // Show initial loading only
                  if (isInitialLoading && state is CarsLoading) {
                    return _buildLoadingState();
                  }

                  // Show error state only for initial load failures
                  if (isInitialLoading && state is CarsError) {
                    return _buildErrorState(state.message);
                  }

                  // Show cars list or empty state
                  if (displayedCars.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildCarsList(displayedCars);
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
