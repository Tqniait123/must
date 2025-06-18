part of 'governorates_cubit.dart';

sealed class GovernoratesState extends Equatable {
  const GovernoratesState();

  @override
  List<Object> get props => [];
}

final class GovernoratesInitial extends GovernoratesState {}

final class GovernoratesLoading extends GovernoratesState {}

final class GovernoratesLoaded extends GovernoratesState {
  final List<Governorate> governorates;

  const GovernoratesLoaded(this.governorates);

  @override
  List<Object> get props => [governorates];
}

final class GovernoratesError extends GovernoratesState {
  final String message;

  const GovernoratesError(this.message);

  @override
  List<Object> get props => [message];
}
