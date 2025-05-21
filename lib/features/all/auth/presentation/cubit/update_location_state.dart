part of 'update_location_cubit.dart';

sealed class UpdateLocationState extends Equatable {
  const UpdateLocationState();

  @override
  List<Object> get props => [];
}

final class UpdateLocationInitial extends UpdateLocationState {}

final class UpdateLocationLoading extends UpdateLocationState {}

final class UpdateLocationSuccess extends UpdateLocationState {
  final AppUser updatedUser;

  const UpdateLocationSuccess(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}

final class UpdateLocationError extends UpdateLocationState {
  final String message;

  const UpdateLocationError(this.message);

  @override
  List<Object> get props => [message];
}
