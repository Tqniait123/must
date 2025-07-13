import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:must_invest/features/profile/data/models/contact_us_model.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';
import 'package:must_invest/features/profile/data/models/privacy_policy_model.dart';
import 'package:must_invest/features/profile/data/models/terms_and_conditions_model.dart';

abstract class PagesRepo {
  // Add your repository methods here
  Future<Either<List<FAQModel>, AppError>> getFaq(String? lang);
  Future<Either<TermsAndConditionsModel, AppError>> getTermsAndConditions(String? lang);
  Future<Either<PrivacyPolicyModel, AppError>> getPrivacyPolicy(String? lang);
  Future<Either<ContactUsModel, AppError>> getContactUs(String? lang);
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

  @override
  Future<Either<TermsAndConditionsModel, AppError>> getTermsAndConditions(String? lang) async {
    try {
      // final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getTermsAndConditions(lang);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<PrivacyPolicyModel, AppError>> getPrivacyPolicy(String? lang) async {
    try {
      // final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getPrivacyPolicy(lang);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<ContactUsModel, AppError>> getContactUs(String? lang) async {
    try {
      // final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getContactUs(lang);

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
