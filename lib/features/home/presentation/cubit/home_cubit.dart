import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';

import '../../data/repositories/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of(context);

  Future<void> chargePoints(String equivalentMoney) async {
    try {
      emit(HomeLoading());
      final result = await _repository.chargePoints(equivalentMoney);
      result.fold((points) => emit(HomeSuccess(points)), (error) => emit(HomeError(error.message)));
    } on AppError catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> withdrawPoints(int id) async {
    try {
      emit(WithdrawPointsLoading());
      final result = await _repository.pointsWithdrawn(id);
      result.fold((success) => emit(WithdrawPointsSuccess()), (error) => emit(WithdrawPointsError(error.message)));
    } on AppError catch (e) {
      emit(WithdrawPointsError(e.message));
    } catch (e) {
      emit(WithdrawPointsError(e.toString()));
    }
  }
}
