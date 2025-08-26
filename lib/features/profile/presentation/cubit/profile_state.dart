part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final dynamic user;
  final String message;

  const ProfileSuccess(this.user, this.message);

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class StartParkingLoading extends ProfileState {}

class StartParkingSuccess extends ProfileState {}

class StartParkingError extends ProfileState {
  final String message;

  const StartParkingError(this.message);

  @override
  List<Object> get props => [message];
}
