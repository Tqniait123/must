import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/datasources/cars_remote_data_source.dart';

abstract class CarRepo {
  Future<Either<List<Car>, AppError>> getMyCars();
  Future<Either<Car, AppError>> getCarDetails(String carId);
  Future<Either<Car, AppError>> addCar(AddCarRequest request);
  Future<Either<Car, AppError>> updateCar(String carId, UpdateCarRequest request);
  Future<Either<bool, AppError>> deleteCar(String carId);
}

class CarRepoImpl implements CarRepo {
  final CarRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  CarRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<List<Car>, AppError>> getMyCars() async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getMyCars(token ?? '');

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(
          AppError(
            message: response.errorMessage,
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<Car, AppError>> getCarDetails(String carId) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getCarDetails(token ?? '', carId);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(
          AppError(
            message: response.errorMessage,
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<Car, AppError>> addCar(AddCarRequest request) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.addCar(token ?? '', request);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(
          AppError(
            message: response.errorMessage,
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<Car, AppError>> updateCar(String carId, UpdateCarRequest request) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.updateCar(token ?? '', carId, request);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(
          AppError(
            message: response.errorMessage,
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<bool, AppError>> deleteCar(String carId) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.deleteCar(token ?? '', carId);

      if (response.isSuccess) {
        return const Left(true);
      } else {
        return Right(
          AppError(
            message: response.errorMessage,
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }
}
