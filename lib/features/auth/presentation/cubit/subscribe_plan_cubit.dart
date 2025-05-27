import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/auth/data/models/plan.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';

part 'subscribe_plan_state.dart';

class SubscribePlanCubit extends Cubit<SubscribePlanState> {
  final AuthRepo _repo;
  SubscribePlanCubit(this._repo) : super(SubscribePlanInitial());

  static SubscribePlanCubit get(context) =>
      BlocProvider.of<SubscribePlanCubit>(context);

  /// The `subscribePlan` function subscribes to a plan, handling loading, success, and error states.
  ///
  /// Args:
  ///   planId (int): The `planId` parameter is an integer that represents the ID of the plan that the
  /// user wants to subscribe to. This ID is used to identify the specific plan that the user is
  /// selecting for subscription.
  Future<void> subscribePlan(int planId) async {
    try {
      emit(SubscribePlanLoading());
      final response = await _repo.subscribePlan(planId);
      response.fold(
        (plan) => emit(SubscribePlanSuccess(plan)),
        (error) => emit(SubscribePlanError(error.message)),
      );
    } on AppError catch (e) {
      emit(SubscribePlanError(e.message));
    } catch (e) {
      emit(SubscribePlanError(e.toString()));
    }
  }
}
