import 'package:equatable/equatable.dart';
import 'package:must_invest/features/history/data/models/history_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistorySuccess extends HistoryState {
  final List<HistoryModel> data;

  const HistorySuccess(this.data);

  @override
  List<Object> get props => [data];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
