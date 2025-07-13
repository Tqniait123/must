import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';

abstract class PagesRepo {
  // Add your repository methods here
  Future<Either<List<FAQModel>, AppError>> getFaq(String? lang);
}

class PagesRepoImpl implements PagesRepo {
  final PagesRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  PagesRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<List<FAQModel>, AppError>> getFaq(String? lang) async {
    try {
      // final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getFaq(lang);

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
