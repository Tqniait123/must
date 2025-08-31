import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/offers/data/models/payment_model.dart';

import '../datasources/home_remote_data_source.dart';

abstract class HomeRepo {
  Future<Either<String, AppError>> chargePoints(String equivalentMoney);
  Future<Either<void, AppError>> pointsWithdrawn(int id);
}

class HomeRepoImpl implements HomeRepo {
  final HomeRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  HomeRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<String, AppError>> chargePoints(String equivalentMoney) async {
    final token = _localDataSource.getToken();
    try {
      final result = await _remoteDataSource.chargePoints(equivalentMoney, token ?? '');
      if (result.isSuccess) {
        return Left((result.data as PaymentModel).paymentUrl);
      } else {
        return Right(AppError(message: result.errorMessage, apiResponse: result, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<void, AppError>> pointsWithdrawn(int id) async {
    final token = _localDataSource.getToken();
    try {
      final result = await _remoteDataSource.pointsWithdrawn(id, token ?? '');
      if (result.isSuccess) {
        return Left(result.data);
      } else {
        return Right(AppError(message: result.errorMessage, apiResponse: result, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }
}
