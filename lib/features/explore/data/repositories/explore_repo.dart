import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';

abstract class ExploreRepo {
  Future<Either<List<Parking>, AppError>> getAllParkings({FilterModel? filter});
}

class ExploreRepoImpl implements ExploreRepo {
  final ExploreRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  ExploreRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<List<Parking>, AppError>> getAllParkings({
    FilterModel? filter,
  }) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getAllParkings(
        token ?? '',
        filter: filter,
      );

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
}
