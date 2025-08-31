import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final String paymentUrl;

  const HomeSuccess(this.paymentUrl);

  @override
  List<Object> get props => [paymentUrl];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

class WithdrawPointsLoading extends HomeState {}

class WithdrawPointsSuccess extends HomeState {}

class WithdrawPointsError extends HomeState {
  final String message;

  const WithdrawPointsError(this.message);

  @override
  List<Object> get props => [message];
}
