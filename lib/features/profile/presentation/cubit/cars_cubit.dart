import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/datasources/cars_remote_data_source.dart';
import 'package:must_invest/features/profile/data/repositories/cars_repo.dart';

part 'cars_state.dart';

class CarCubit extends Cubit<CarState> {
  final CarRepo carRepo;
  List<Car> _currentCars = [];

  CarCubit(this.carRepo) : super(CarInitial());

  static CarCubit get(context) => BlocProvider.of<CarCubit>(context);

  Future<void> getMyCars() async {
    try {
      emit(CarsLoading());
      final response = await carRepo.getMyCars();
      response.fold((cars) {
        _currentCars = List.from(cars);
        emit(CarsSuccess(cars));
      }, (error) => emit(CarsError(error.message)));
    } on AppError catch (e) {
      emit(CarsError(e.message));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  Future<void> getCarDetails(String carId) async {
    try {
      emit(CarDetailsLoading());
      final response = await carRepo.getCarDetails(carId);
      response.fold((car) => emit(CarDetailsSuccess(car)), (error) => emit(CarDetailsError(error.message)));
    } on AppError catch (e) {
      emit(CarDetailsError(e.message));
    } catch (e) {
      emit(CarDetailsError(e.toString()));
    }
  }

  Future<void> addCar(AddCarRequest request) async {
    try {
      emit(AddCarLoading());
      final response = await carRepo.addCar(request);
      response.fold((newCar) {
        // Optimistically add the new car to the list
        _currentCars.add(newCar);
        emit(AddCarSuccess(newCar));
        // Update the cars list with the new car included
        emit(CarsSuccess(List.from(_currentCars)));
      }, (error) => emit(AddCarError(error.message)));
    } on AppError catch (e) {
      emit(AddCarError(e.message));
    } catch (e) {
      emit(AddCarError(e.toString()));
    }
  }

  Future<void> updateCar(String carId, UpdateCarRequest request) async {
    try {
      emit(UpdateCarLoading());
      final response = await carRepo.updateCar(carId, request);
      response.fold((updatedCar) {
        // Optimistically update the car in the list
        final index = _currentCars.indexWhere((car) => car.id == carId);
        if (index != -1) {
          _currentCars[index] = updatedCar;
        }
        emit(UpdateCarSuccess(updatedCar));
        // Update the cars list with the updated car
        emit(CarsSuccess(List.from(_currentCars)));
      }, (error) => emit(UpdateCarError(error.message)));
    } on AppError catch (e) {
      emit(UpdateCarError(e.message));
    } catch (e) {
      emit(UpdateCarError(e.toString()));
    }
  }

  Future<void> deleteCar(String carId) async {
    try {
      // Optimistically remove the car from the list immediately
      final carToDelete = _currentCars.firstWhere((car) => car.id == carId);
      _currentCars.removeWhere((car) => car.id == carId);

      // Update UI immediately
      emit(CarsSuccess(List.from(_currentCars)));

      final response = await carRepo.deleteCar(carId);
      response.fold(
        (success) {
          // emit(DeleteCarSuccess());
          // Keep the optimistic update - car already removed from list
        },
        (error) {
          // Rollback: add the car back if deletion failed
          _currentCars.add(carToDelete);
          emit(DeleteCarError(error.message));
          emit(CarsSuccess(List.from(_currentCars)));
        },
      );
    } on AppError catch (e) {
      emit(DeleteCarError(e.message));
    } catch (e) {
      emit(DeleteCarError(e.toString()));
    }
  }

  // Helper method to manually refresh if needed
  Future<void> refreshCars() async {
    await getMyCars();
  }

  // Get current cars list
  List<Car> get currentCars => List.from(_currentCars);
}
