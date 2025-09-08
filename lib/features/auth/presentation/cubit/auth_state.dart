part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ForgetPasswordLoading extends AuthState {}

class ForgetPasswordSentOTP extends AuthState {
  final String message;

  const ForgetPasswordSentOTP({required this.message});
}

class ForgetPasswordError extends AuthState {
  final String message;

  const ForgetPasswordError(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordLoading extends AuthState {}

class ResetPasswordSentOTP extends AuthState {}

class ResetPasswordSuccess extends AuthState {}

class ResetPasswordError extends AuthState {
  final String message;

  const ResetPasswordError(this.message);

  @override
  List<Object> get props => [message];
}

class RegisterSuccess extends AuthState {
  final String message;

  const RegisterSuccess(this.message);
}

class ResendOTPLoading extends AuthState {}

class ResendOTPSuccess extends AuthState {
  final String message;

  const ResendOTPSuccess(this.message);
}

class ResendOTPError extends AuthState {
  final String message;

  const ResendOTPError(this.message);

  @override
  List<Object> get props => [message];
}

// class ResetPasswordSuccess extends AuthState {}

class DeleteAccountLoading extends AuthState {}

class DeleteAccountSuccess extends AuthState {}

class DeleteAccountError extends AuthState {
  final String message;

  const DeleteAccountError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthUnverified extends AuthState {
  final String message;

  AuthUnverified(this.message);
}
