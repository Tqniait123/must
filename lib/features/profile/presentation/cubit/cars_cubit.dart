import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/datasources/cars_remote_data_source.dart';
import 'package:must_invest/features/profile/data/repositories/cars_repo.dart';

part 'cars_state.dart';

class CarCubit extends Cubit<CarState> {
  final CarRepo carRepo;
  CarCubit(this.carRepo) : super(CarInitial());

  static CarCubit get(context) => BlocProvider.of<CarCubit>(context);

  Future<void> getMyCars() async {
    try {
      emit(CarsLoading());
      final response = await carRepo.getMyCars();
      response.fold((cars) => emit(CarsSuccess(cars)), (error) => emit(CarsError(error.message)));
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
      response.fold((car) => emit(AddCarSuccess(car)), (error) => emit(AddCarError(error.message)));
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
      response.fold((car) => emit(UpdateCarSuccess(car)), (error) => emit(UpdateCarError(error.message)));
    } on AppError catch (e) {
      emit(UpdateCarError(e.message));
    } catch (e) {
      emit(UpdateCarError(e.toString()));
    }
  }

  Future<void> deleteCar(String carId) async {
    try {
      emit(DeleteCarLoading());
      final response = await carRepo.deleteCar(carId);
      response.fold((success) => emit(DeleteCarSuccess()), (error) => emit(DeleteCarError(error.message)));
    } on AppError catch (e) {
      emit(DeleteCarError(e.message));
    } catch (e) {
      emit(DeleteCarError(e.toString()));
    }
  }

  // Helper method to refresh cars list after add/update/delete
  Future<void> refreshCars() async {
    await getMyCars();
  }
}
