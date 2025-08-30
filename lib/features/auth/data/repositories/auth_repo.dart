import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/auth/data/models/auth_model.dart';
import 'package:must_invest/features/auth/data/models/city.dart';
import 'package:must_invest/features/auth/data/models/country.dart';
import 'package:must_invest/features/auth/data/models/governorate.dart';
import 'package:must_invest/features/auth/data/models/login_params.dart';
import 'package:must_invest/features/auth/data/models/login_with_google_params.dart';
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/data/models/verify_params.dart';

abstract class AuthRepo {
  Future<Either<User, AppError>> autoLogin();
  Future<Either<AuthModel, AppError>> login(LoginParams params);
  Future<Either<AuthModel, AppError>> loginWithGoogle();
  Future<Either<AuthModel, AppError>> loginWithApple();
  Future<Either<String, AppError>> register(RegisterParams params);
  Future<Either<AuthModel, AppError>> verifyRegistration(VerifyParams params);
  Future<Either<void, AppError>> verifyPasswordReset(VerifyParams params);
  Future<Either<String, AppError>> resendOTP(String phone);
  Future<Either<void, AppError>> forgetPassword(String email);
  Future<Either<void, AppError>> resetPassword(ResetPasswordParams params);
  Future<Either<List<Country>, AppError>> getCountries(); // List<Country>
  Future<Either<List<Governorate>, AppError>> getGovernorates(int countryId); // List<Governorate>
  Future<Either<List<City>, AppError>> getCities(int governorateId); // List<City>
  Future<Either<void, AppError>> deleteAccount(); // List<City>
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
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
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
        _localDataSource.saveToken(response.data?.token ?? '');
        _localDataSource.setRememberMe(params.isRemembered);
        // if (params.isRemembered) {
        // }
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<AuthModel, AppError>> loginWithGoogle() async {
    try {
      // Initialize GoogleSignIn with serverClientId for Android
      await GoogleSignIn.instance.initialize(
        serverClientId: '292970330572-3l6t8obv09qsjpi7s22j93plkm5gq8n4.apps.googleusercontent.com',
      );

      // Check if Google Sign-In is available on this platform
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return Right(AppError(message: 'Google Sign-In is not supported on this platform', type: ErrorType.api));
      }

      // Attempt to sign in with Google
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create user parameters
      LoginWithGoogleParams user = LoginWithGoogleParams(
        displayName: googleUser.displayName ?? '',
        email: googleUser.email,
        id: googleUser.id,
        photoUrl: googleUser.photoUrl ?? '',
        deviceToken: '', // You might want to get FCM token here
      );

      log('Google Sign-In successful for user: ${googleUser.email}');

      // Call your backend API
      final response = await _remoteDataSource.loginWithGoogle(user);

      if (response.isSuccess) {
        // Save token locally
        await _localDataSource.saveToken(response.accessToken ?? '');
        log('Authentication successful, token saved');
        return Left(response.data!);
      } else {
        return Right(
          AppError(
            message: response.errorMessage ?? 'Authentication failed',
            apiResponse: response,
            type: ErrorType.api,
          ),
        );
      }
    } on GoogleSignInException catch (e) {
      // Handle specific Google Sign-In exceptions
      // String errorMessage = _getGoogleSignInErrorMessage(e);
      log('GoogleSignInException: ${e.toString()}');

      return Right(AppError(message: 'An error occurred during Google Sign-In', type: ErrorType.api));
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      String errorMessage = _getPlatformExceptionMessage(e);
      log('PlatformException during Google Sign-In: ${e.toString()}');

      return Right(AppError(message: errorMessage, type: ErrorType.api));
    } catch (e) {
      // Handle any other unexpected errors
      log('Unexpected error during Google Sign-In: ${e.toString()}');
      return Right(AppError(message: 'An unexpected error occurred during sign-in', type: ErrorType.unknown));
    }
  }

  // Helper method to get user-friendly error messages for platform exceptions
  String _getPlatformExceptionMessage(PlatformException e) {
    switch (e.code) {
      case 'sign_in_failed':
        return 'Sign-in failed. Please try again';
      case 'network_error':
        return 'Network error. Please check your internet connection';
      case 'sign_in_canceled':
        return 'Sign-in was cancelled';
      default:
        // Handle specific Google Play Services errors
        if (e.message?.contains('ApiException: 10') == true) {
          return 'Configuration error. Please check your app setup';
        } else if (e.message?.contains('ApiException: 7') == true) {
          return 'Network error. Please try again';
        }
        return 'Sign-in failed: ${e.message ?? 'Unknown error'}';
    }
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
  Future<Either<String, AppError>> register(RegisterParams params) async {
    try {
      final response = await _remoteDataSource.register(params);

      if (response.isSuccess) {
        // _localDataSource.saveToken(response.accessToken ?? '');
        return Left(response.message);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
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
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<void, AppError>> resetPassword(ResetPasswordParams params) async {
    try {
      final response = await _remoteDataSource.resetPassword(params);

      if (response.isSuccess) {
        return const Left(null);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<List<City>, AppError>> getCities(int governorateId) async {
    try {
      final response = await _remoteDataSource.getCities(governorateId);

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
  Future<Either<List<Country>, AppError>> getCountries() async {
    try {
      final response = await _remoteDataSource.getCountries();

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
  Future<Either<List<Governorate>, AppError>> getGovernorates(int countryId) async {
    try {
      final response = await _remoteDataSource.getGovernorates(countryId);

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
  Future<Either<AuthModel, AppError>> verifyRegistration(VerifyParams params) async {
    try {
      final response = await _remoteDataSource.verifyRegistration(params);

      if (response.isSuccess) {
        _localDataSource.saveToken(response.data?.token ?? '');
        _localDataSource.setRememberMe(true);
        // _localDataSource.saveToken(response.data?.token ?? '');
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<String, AppError>> resendOTP(String phone) async {
    try {
      final response = await _remoteDataSource.resendOtp(phone);

      if (response.isSuccess) {
        return Left(response.message);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<void, AppError>> verifyPasswordReset(VerifyParams params) async {
    try {
      final response = await _remoteDataSource.verifyPasswordReset(params);

      if (response.isSuccess) {
        return const Left(null);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<void, AppError>> deleteAccount() async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.deleteAccount(token ?? '');

      if (response.isSuccess) {
        return const Left(null);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }
}
