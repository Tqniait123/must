import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/all/auth/data/models/plan.dart';
import 'package:must_invest/features/all/auth/data/repositories/auth_repo.dart';

part 'subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final AuthRepo _repo;
  SubscriptionsCubit(this._repo) : super(SubscriptionsInitial());

  static SubscriptionsCubit get(context) =>
      BlocProvider.of<SubscriptionsCubit>(context);

  /// The function `getPlans` fetches plans data from a repository and emits loading, success, or error
  /// states accordingly.
  Future<void> getPlans() async {
    try {
      emit(SubscriptionsLoading());
      final response = await _repo.getPlans();
      response.fold(
        (plans) => emit(SubscriptionsSuccess(plans)),
        (error) => emit(SubscriptionsError(error.message)),
      );
    } on AppError catch (e) {
      emit(SubscriptionsError(e.message));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }
}
