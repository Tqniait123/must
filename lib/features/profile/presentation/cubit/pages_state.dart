import 'package:equatable/equatable.dart';

abstract class PagesState extends Equatable {
  const PagesState();

  @override
  List<Object> get props => [];
}

class PagesInitial extends PagesState {}

class PagesLoading extends PagesState {}

class PagesSuccess extends PagesState {
  final dynamic data;

  const PagesSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class PagesError extends PagesState {
  final String message;

  const PagesError(this.message);

  @override
  List<Object> get props => [message];
}

