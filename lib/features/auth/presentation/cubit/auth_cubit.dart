import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/auth/data/models/login_params.dart';
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/data/models/verify_params.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _repo;
  AuthCubit(this._repo) : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  /// The `autoLogin` function attempts to automatically log in a user, handling different outcomes and
  /// emitting corresponding states.
  Future<void> autoLogin() async {
    try {
      emit(AuthLoading());
      final response = await _repo.autoLogin();
      response.fold(
        (user) => emit(AuthSuccess(user)),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `login` function in Dart handles user authentication by calling a repository method and emitting
  /// loading, success, or error states based on the response.
  ///
  /// Args:
  ///   params (LoginParams): The `login` method takes a `LoginParams` object as a parameter. This object
  /// likely contains the necessary information for the login process, such as username, password, or any
  /// other credentials required for authentication. The method then attempts to log in using the provided
  /// parameters and handles different scenarios based on the
  Future<void> login(LoginParams params) async {
    try {
      emit(AuthLoading());
      final response = await _repo.login(params);
      response.fold(
        (authModel) => emit(AuthSuccess(authModel.user)),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `loginWithGoogle` function handles Google OAuth authentication by calling the repository method
  /// and emitting appropriate states based on the response.
  ///
  /// This method attempts to authenticate the user through Google Sign-In. It emits:
  /// - AuthLoading state while processing
  /// - AuthSuccess state with user data on successful authentication
  /// - AuthError state if authentication fails
  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());
      final response = await _repo.loginWithGoogle();
      response.fold(
        (authModel) => emit(AuthSuccess(authModel.user)),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `loginWithApple` function handles Apple OAuth authentication by calling the repository method
  /// and emitting appropriate states based on the response.
  ///
  /// This method attempts to authenticate the user through Apple Sign-In. It emits:
  /// - AuthLoading state while processing
  /// - AuthSuccess state with user data on successful authentication
  /// - AuthError state if authentication fails
  Future<void> loginWithApple() async {
    try {
      emit(AuthLoading());
      final response = await _repo.loginWithApple();
      response.fold(
        (authModel) => emit(AuthSuccess(authModel.user)),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The function `register` in Dart is responsible for handling user registration, including loading
  /// state, success, and error handling.
  ///
  /// Args:
  ///   params (RegisterParams): The `params` parameter in the `register` method likely contains
  /// information needed for user registration, such as username, email, password, etc. It is used to
  /// pass these registration details to the `_repo.register` method for processing.
  Future<void> register(RegisterParams params) async {
    try {
      emit(AuthLoading());
      final response = await _repo.register(params);
      response.fold(
        (authModel) => emit(RegisterSuccess()),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `forgetPassword` function in Dart sends a password reset request using the provided email and
  /// handles different outcomes such as loading, success, and errors.
  ///
  /// Args:
  ///   email (String): The `email` parameter in the `forgetPassword` method is a string representing the
  /// email address of the user who is requesting to reset their password.
  Future<void> forgetPassword(String email) async {
    try {
      emit(ForgetPasswordLoading());
      final response = await _repo.forgetPassword(email);
      response.fold(
        (function) => emit(ForgetPasswordSentOTP()),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(ForgetPasswordError(e.message));
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }

  /// The function `resetPassword` in Dart attempts to reset a password, handling different outcomes and
  /// emitting corresponding states.
  ///
  /// Args:
  ///   params (ResetPasswordParams): The `resetPassword` function takes a `ResetPasswordParams` object
  /// as a parameter. This object likely contains information needed to reset a user's password, such as
  /// the user's email or phone number. The function then attempts to reset the password using the
  /// provided parameters and handles different scenarios based on the
  Future<void> resetPassword(ResetPasswordParams params) async {
    try {
      emit(ResetPasswordLoading());
      final response = await _repo.resetPassword(params);
      response.fold(
        (function) => emit(ResetPasswordSentOTP()),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(ResetPasswordError(e.message));
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }

  /// The `verifyRegistration` function handles the verification of user registration by calling the repository
  /// method and emitting appropriate states based on the response.
  ///
  /// Args:
  ///   params (VerifyParams): Contains the verification details needed for registration verification,
  /// such as verification code or token.
  Future<void> verifyRegistration(VerifyParams params) async {
    try {
      emit(AuthLoading());
      final response = await _repo.verifyRegistration(params);
      response.fold(
        (authModel) => emit(AuthSuccess(authModel.user)),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `verifyPasswordReset` function handles the verification of password reset by calling the repository
  /// method and emitting appropriate states based on the response.
  ///
  /// Args:
  ///   params (VerifyParams): Contains the verification details needed for password reset verification,
  /// such as verification code or token.
  Future<void> verifyPasswordReset(VerifyParams params) async {
    try {
      emit(AuthLoading());
      final response = await _repo.verifyPasswordReset(params);
      response.fold(
        (authModel) => emit(ResetPasswordSentOTP()),
        (error) => emit(AuthError(error.message)),
      );
    } on AppError catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// The `resendOTP` function handles resending OTP verification code by calling the repository
  /// method and emitting appropriate states based on the response.
  ///
  /// Args:
  ///   phone (String): The phone number to which the OTP should be resent
  Future<void> resendOTP(String phone) async {
    try {
      emit(ResendOTPLoading());
      final response = await _repo.resendOTP(phone);
      response.fold(
        (_) => emit(ResendOTPSuccess()),
        (error) => emit(ResendOTPError(error.message)),
      );
    } on AppError catch (e) {
      emit(ResendOTPError(e.message));
    } catch (e) {
      emit(ResendOTPError(e.toString()));
    }
  }
}
