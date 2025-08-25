part of 'explore_cubit.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object> get props => [];
}

class ExploreInitial extends ExploreState {}

class ParkingsLoading extends ExploreState {}

class ParkingsSuccess extends ExploreState {
  final List<Parking> parkings;

  const ParkingsSuccess(this.parkings);

  @override
  List<Object> get props => [identityHashCode(this)];
}

class ParkingsError extends ExploreState {
  final String message;

  const ParkingsError(this.message);

  @override
  List<Object> get props => [message];
}
