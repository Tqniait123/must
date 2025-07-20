import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';

import '../../data/repositories/history_repo.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepo _repository;

  HistoryCubit(this._repository) : super(HistoryInitial());

  static HistoryCubit get(context) => BlocProvider.of<HistoryCubit>(context);

  Future<void> getAllHistory() async {
    try {
      emit(HistoryLoading());
      final response = await _repository.getHistory();
      response.fold((history) => emit(HistorySuccess(history)), (error) => emit(HistoryError(error.message)));
    } on AppError catch (e) {
      emit(HistoryError(e.message));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
