import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:must_invest/features/profile/data/models/about_us_model.dart';
import 'package:must_invest/features/profile/data/models/contact_us_model.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';
import 'package:must_invest/features/profile/data/models/privacy_policy_model.dart';
import 'package:must_invest/features/profile/data/models/terms_and_conditions_model.dart';
import 'package:must_invest/features/profile/data/models/update_profile_params.dart';

abstract class PagesRepo {
  // Add your repository methods here
  Future<Either<List<FAQModel>, AppError>> getFaq(String? lang);
  Future<Either<TermsAndConditionsModel, AppError>> getTermsAndConditions(String? lang);
  Future<Either<AboutUsModel, AppError>> getAboutUs(String? lang);
  Future<Either<PrivacyPolicyModel, AppError>> getPrivacyPolicy(String? lang);
  Future<Either<ContactUsModel, AppError>> getContactUs(String? lang);
  Future<Either<User, AppError>> updateProfile(UpdateProfileParams params);
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

  @override
  Future<Either<AboutUsModel, AppError>> getAboutUs(String? lang) async {
    try {
      // final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getAboutUs(lang);

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
  Future<Either<User, AppError>> updateProfile(UpdateProfileParams params) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.updateProfile(token ?? '', params);

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
