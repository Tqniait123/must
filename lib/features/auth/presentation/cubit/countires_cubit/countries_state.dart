part of 'countries_cubit.dart';

sealed class CountriesState extends Equatable {
  const CountriesState();

  @override
  List<Object> get props => [];
}

final class CountriesInitial extends CountriesState {}

final class CountriesLoading extends CountriesState {}

final class CountriesLoaded extends CountriesState {
  final List<Country> countries;

  const CountriesLoaded(this.countries);

  @override
  List<Object> get props => [countries];
}

final class CountriesError extends CountriesState {
  final String message;

  const CountriesError(this.message);

  @override
  List<Object> get props => [message];
}
