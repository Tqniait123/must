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

class ForgetPasswordSentOTP extends AuthState {}

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

class RegisterSuccess extends AuthState {}

class ResendOTPLoading extends AuthState {}

class ResendOTPSuccess extends AuthState {}

class ResendOTPError extends AuthState {
  final String message;

  const ResendOTPError(this.message);

  @override
  List<Object> get props => [message];
}

// class ResetPasswordSuccess extends AuthState {}
