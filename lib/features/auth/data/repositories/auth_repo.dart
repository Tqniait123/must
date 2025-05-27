import 'package:dartz/dartz.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/auth/data/models/auth_model.dart';
import 'package:must_invest/features/auth/data/models/brands.dart';
import 'package:must_invest/features/auth/data/models/login_params.dart';
import 'package:must_invest/features/auth/data/models/plan.dart';
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AuthRepo {
  Future<Either<AuthModel, AppError>> autoLogin();
  Future<Either<AuthModel, AppError>> login(LoginParams params);
  Future<Either<AuthModel, AppError>> loginWithGoogle();
  Future<Either<AuthModel, AppError>> loginWithApple();
  Future<Either<AuthModel, AppError>> register(RegisterParams params);
  Future<Either<void, AppError>> forgetPassword(String email);
  Future<Either<void, AppError>> resetPassword(ResetPasswordParams params);

  Future<Either<List<SubscriptionPlan>, AppError>> getPlans();
  Future<Either<SubscriptionPlan, AppError>> subscribePlan(int planId);

  Future<Either<List<Brand>, AppError>> getBrands(int planId);

  Future<Either<AppUser, AppError>> updateLocation(
    double lat,
    double long,
    String address,
  );
}

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final MustIvestPreferences _localDataSource;

  AuthRepoImpl(this._remoteDataSource, this._localDataSource);

  /// This function attempts to automatically log in a user using a token retrieved from local storage
  /// and returns either the user data or an error.
  ///
  /// Returns:
  ///   The `autoLogin` method is returning a `Future` that will either contain an `AppUser` object if
  /// the login is successful, or an `AppError` object if there is an error during the login process.
  @override
  Future<Either<AuthModel, AppError>> autoLogin() async {
    final token = _localDataSource.getToken();
    final response = await _remoteDataSource.autoLogin(token ?? '');
    if (response.status) {
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This function performs a login operation, saving the token if successful and throwing an error if
  /// not.
  ///
  /// Args:
  ///   params (LoginParams): It looks like the `login` method is attempting to authenticate a user
  /// based on the provided `LoginParams`. The `params` variable likely contains information such as the
  /// user's credentials (e.g., username and password) needed for the login process.
  ///
  /// Returns:
  ///   The `login` method is returning a `Future` that resolves to an `Either` type. The left side of
  /// the `Either` contains an `AuthModel` object if the login is successful, and the right side
  /// contains an `AppError` object if there is an error during the login process.
  @override
  Future<Either<AuthModel, AppError>> login(LoginParams params) async {
    final response = await _remoteDataSource.login(params);
    if (response.status && params.isRemembered) {
      _localDataSource.saveToken((response as SuccessResponse).data.token);
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// Performs Google Sign-In authentication and returns the authentication result
  ///
  /// This function:
  /// 1. Initiates Google Sign-In flow
  /// 2. Creates login params from Google user data
  /// 3. Calls remote data source to authenticate
  /// 4. Saves authentication token on success
  ///
  /// Returns:
  ///   Either<AuthModel, AppError>: Returns AuthModel on successful login,
  ///   or AppError if authentication fails
  @override
  Future<Either<AuthModel, AppError>> loginWithGoogle() async {
    throw UnimplementedError();
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // log(googleUser.toString());
    // LoginWithGoogleParams user = LoginWithGoogleParams(
    //   displayName: googleUser?.displayName ?? '',
    //   email: googleUser?.email ?? '',
    //   id: googleUser?.id ?? '',
    //   photoUrl: googleUser?.photoUrl ?? '',
    //   deviceToken: '',
    // );
    // final loginWithGoogleParams = user;
    // final response = await _remoteDataSource.loginWithGoogle(
    //   loginWithGoogleParams,
    // );
    // if (response.status) {
    //   _localDataSource.saveToken((response as SuccessResponse).data.token);
    //   return Left((response as SuccessResponse).data);
    // } else {
    //   throw AppError(
    //     message: response.message,
    //     apiResponse: response,
    //     type: ErrorType.api,
    //   );
    // }
  }

  /// Performs Apple Sign-In authentication and returns the authentication result
  ///
  /// This function:
  /// 1. Initiates Apple Sign-In flow
  /// 2. Creates login params from Apple user data
  /// 3. Calls remote data source to authenticate
  /// 4. Saves authentication token on success
  ///
  /// Returns:
  ///   Either<AuthModel, AppError>: Returns AuthModel on successful login,
  ///   or AppError if authentication fails
  @override
  Future<Either<AuthModel, AppError>> loginWithApple() async {
    throw UnimplementedError();
    // final appleCredentials = await SignInWithApple.getAppleIDCredential(
    //   scopes: [
    //     AppleIDAuthorizationScopes.email,
    //     AppleIDAuthorizationScopes.fullName,
    //   ],
    // );

    // final response = await _remoteDataSource.loginWithApple(
    //   LoginWithAppleParams(
    //     email: appleCredentials.email,
    //     givenName: appleCredentials.givenName,
    //     familyName: appleCredentials.familyName,
    //     identityToken: appleCredentials.identityToken ?? '',
    //     authorizationCode: appleCredentials.authorizationCode,
    //     deviceToken: '',
    //   ),
    // );

    // if (response.status) {
    //   _localDataSource.saveToken((response as SuccessResponse).data.token);
    //   return Left((response as SuccessResponse).data);
    // } else {
    //   throw AppError(
    //     message: response.message,
    //     apiResponse: response,
    //     type: ErrorType.api,
    //   );
    // }
  }

  /// This function registers a user with the provided parameters and returns either an AuthModel or an
  /// AppError based on the response from the remote data source.
  ///
  /// Args:
  ///   params (RegisterParams): The `register` method takes a `RegisterParams` object as a parameter.
  /// This object likely contains the necessary information for registering a user, such as username,
  /// email, password, etc. The method then uses this `RegisterParams` object to call the
  /// `_remoteDataSource.register` method to attempt user
  ///
  /// Returns:
  ///   The `register` method returns a `Future` that resolves to an `Either` type, which can contain
  /// either an `AuthModel` or an `AppError`.
  @override
  Future<Either<AuthModel, AppError>> register(RegisterParams params) async {
    final response = await _remoteDataSource.register(params);
    if (response.status) {
      _localDataSource.saveToken((response as SuccessResponse).data.token);
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This function sends a request to the remote data source to reset a user's password and handles the
  /// response accordingly.
  ///
  /// Args:
  ///   email (String): The `email` parameter in the `forgetPassword` method is a string representing the
  /// email address of the user who wants to reset their password.
  ///
  /// Returns:
  ///   The `forgetPassword` method is returning a `Future` that resolves to an `Either` type. The `Left`
  /// side of the `Either` contains a function that returns `void`, and the `Right` side contains an
  /// `AppError` object.
  @override
  Future<Either<void, AppError>> forgetPassword(String email) async {
    final response = await _remoteDataSource.forgetPassword(email);
    if (response.status) {
      _localDataSource.saveToken((response as SuccessResponse).data.token);
      return Left(() {});
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This function resets a user's password by calling a remote data source and saving the token
  /// locally if the response is successful, otherwise it throws an AppError.
  ///
  /// Args:
  ///   params (ResetPasswordParams): It looks like the code snippet you provided is a method for
  /// resetting a password. The method takes a `ResetPasswordParams` object as a parameter. The
  /// `ResetPasswordParams` object likely contains information needed to reset a user's password, such
  /// as the user's email or username.
  ///
  /// Returns:
  ///   The `resetPassword` method is returning a `Future` that resolves to an `Either` type. The `Left`
  /// side of the `Either` contains a function that returns `void`, while the `Right` side contains an
  /// `AppError` object.
  @override
  Future<Either<void, AppError>> resetPassword(
    ResetPasswordParams params,
  ) async {
    final response = await _remoteDataSource.resetPassword(params);
    if (response.status) {
      _localDataSource.saveToken((response as SuccessResponse).data.token);
      return Left(() {});
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This function retrieves subscription plans from a remote data source and returns either a list of
  /// plans or an error.
  ///
  /// Returns:
  ///   A `Future` that will either return a list of `SubscriptionPlan` objects wrapped in a `Left` or
  /// an `AppError` object if there is an error.
  @override
  Future<Either<List<SubscriptionPlan>, AppError>> getPlans() async {
    final response = await _remoteDataSource.getPLans();
    if (response.status) {
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This Dart function subscribes to a plan using a token and returns either the subscription plan or
  /// an AppError.
  ///
  /// Args:
  ///   planId (int): The `planId` parameter is an integer that represents the ID of the subscription
  /// plan that the user wants to subscribe to.
  ///
  /// Returns:
  ///   A `Future` that will either return an `Either` containing a `SubscriptionPlan` on the left side
  /// or an `AppError` on the right side.
  @override
  Future<Either<SubscriptionPlan, AppError>> subscribePlan(int planId) async {
    final token = _localDataSource.getToken();
    final response = await _remoteDataSource.subscribePlan(planId, token ?? '');
    if (response.status) {
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  /// This function retrieves a list of brands based on a given plan ID, handling success and error
  /// responses accordingly.
  ///
  /// Args:
  ///   planId (int): The `planId` parameter in the `getBrands` method is used to specify the ID of the
  /// plan for which you want to retrieve the brands. This ID is passed to the method to fetch the brands
  /// associated with that particular plan.
  ///
  /// Returns:
  ///   A `Future` that will either return a list of `Brand` objects wrapped in a `Left` or an `AppError`
  /// object if there is an error.
  @override
  Future<Either<List<Brand>, AppError>> getBrands(int planId) async {
    final response = await _remoteDataSource.getBrands(planId);
    if (response.status) {
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }

  @override
  Future<Either<AppUser, AppError>> updateLocation(
    double lat,
    double long,
    String address,
  ) async {
    final token = _localDataSource.getToken();
    final response = await _remoteDataSource.updateLocation(
      token ?? '',
      lat,
      long,
      address,
    );
    if (response.status) {
      return Left((response as SuccessResponse).data);
    } else {
      throw AppError(
        message: response.message,
        apiResponse: response,
        type: ErrorType.api,
      );
    }
  }
}
