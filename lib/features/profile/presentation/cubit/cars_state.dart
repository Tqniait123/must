part of 'cars_cubit.dart';

abstract class CarState extends Equatable {
  const CarState();

  @override
  List<Object> get props => [];
}

class CarInitial extends CarState {}

// Get My Cars States
class CarsLoading extends CarState {}

class CarsSuccess extends CarState {
  final List<Car> cars;

  const CarsSuccess(this.cars);

  @override
  List<Object> get props => [identityHashCode(this)];
}

class CarsError extends CarState {
  final String message;

  const CarsError(this.message);

  @override
  List<Object> get props => [message];
}

// Get Car Details States
class CarDetailsLoading extends CarState {}

class CarDetailsSuccess extends CarState {
  final Car car;

  const CarDetailsSuccess(this.car);

  @override
  List<Object> get props => [car];
}

class CarDetailsError extends CarState {
  final String message;

  const CarDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

// Add Car States
class AddCarLoading extends CarState {}

class AddCarSuccess extends CarState {
  final Car car;

  const AddCarSuccess(this.car);

  @override
  List<Object> get props => [car];
}

class AddCarError extends CarState {
  final String message;

  const AddCarError(this.message);

  @override
  List<Object> get props => [message];
}

// Update Car States
class UpdateCarLoading extends CarState {}

class UpdateCarSuccess extends CarState {
  final Car car;

  const UpdateCarSuccess(this.car);

  @override
  List<Object> get props => [car];
}

class UpdateCarError extends CarState {
  final String message;

  const UpdateCarError(this.message);

  @override
  List<Object> get props => [message];
}

// Delete Car States
class DeleteCarLoading extends CarState {}

class DeleteCarSuccess extends CarState {}

class DeleteCarError extends CarState {
  final String message;

  const DeleteCarError(this.message);

  @override
  List<Object> get props => [message];
}
