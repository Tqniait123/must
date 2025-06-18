import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/auth/data/models/auth_model.dart';
import 'package:must_invest/features/auth/data/models/login_params.dart';
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

abstract class AuthRepo {
  Future<Either<User, AppError>> autoLogin();
  Future<Either<AuthModel, AppError>> login(LoginParams params);
  Future<Either<AuthModel, AppError>> loginWithGoogle();
  Future<Either<AuthModel, AppError>> loginWithApple();
  Future<Either<AuthModel, AppError>> register(RegisterParams params);
  Future<Either<void, AppError>> forgetPassword(String email);
  Future<Either<void, AppError>> resetPassword(ResetPasswordParams params);
}

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  AuthRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<User, AppError>> autoLogin() async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.autoLogin(token ?? '');

      if (response.isSuccess) {
        _localDataSource.saveToken(response.accessToken ?? '');
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
  Future<Either<AuthModel, AppError>> login(LoginParams params) async {
    try {
      final response = await _remoteDataSource.login(params);

      if (response.isSuccess) {
        if (params.isRemembered) {
          _localDataSource.saveToken(response.accessToken ?? '');
        }
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
  Future<Either<AuthModel, AppError>> loginWithGoogle() async {
    throw UnimplementedError();
    // try {
    //   final response = await _remoteDataSource.loginWithGoogle();

    //   if (response.isSuccess) {
    //     _localDataSource.saveToken(response.accessToken ?? '');
    //     return Left(response.data!);
    //   } else {
    //     return Right(
    //       AppError(
    //         message: response.errorMessage,
    //         apiResponse: response,
    //         type: ErrorType.api,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    // }
  }

  @override
  Future<Either<AuthModel, AppError>> loginWithApple() async {
    throw UnimplementedError();
    // try {
    //   final response = await _remoteDataSource.loginWithApple(

    //   );

    //   if (response.isSuccess) {
    //     _localDataSource.saveToken(response.accessToken?? '');
    //     return Left(response.data!);
    //   } else {
    //     return Right(AppError(
    //       message: response.errorMessage,
    //       apiResponse: response,
    //       type: ErrorType.api,
    //     ));
    //   }
    // } catch (e) {
    //   return Right(AppError(
    //     message: e.toString(),
    //     type: ErrorType.unknown,
    //   ));
    // }
  }

  @override
  Future<Either<AuthModel, AppError>> register(RegisterParams params) async {
    try {
      final response = await _remoteDataSource.register(params);

      if (response.isSuccess) {
        _localDataSource.saveToken(response.accessToken ?? '');
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
  Future<Either<void, AppError>> forgetPassword(String email) async {
    try {
      final response = await _remoteDataSource.forgetPassword(email);

      if (response.isSuccess) {
        return const Left(null);
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
  Future<Either<void, AppError>> resetPassword(
    ResetPasswordParams params,
  ) async {
    try {
      final response = await _remoteDataSource.resetPassword(params);

      if (response.isSuccess) {
        return const Left(null);
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
