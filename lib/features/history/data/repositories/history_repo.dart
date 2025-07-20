import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/history/data/models/history_model.dart';

import '../datasources/history_remote_data_source.dart';

abstract class HistoryRepo {
  Future<Either<List<HistoryModel>, AppError>> getHistory();
}

class HistoryRepoImpl implements HistoryRepo {
  final HistoryRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  HistoryRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<List<HistoryModel>, AppError>> getHistory() async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getHistory(token ?? '');

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }
}
