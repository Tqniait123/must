part of 'subscribe_plan_cubit.dart';

sealed class SubscribePlanState extends Equatable {
  const SubscribePlanState();

  @override
  List<Object> get props => [];
}

final class SubscribePlanInitial extends SubscribePlanState {}

final class SubscribePlanLoading extends SubscribePlanState {}

final class SubscribePlanSuccess extends SubscribePlanState {
  final SubscriptionPlan plan;

  const SubscribePlanSuccess(this.plan);

  @override
  List<Object> get props => [plan];
}

final class SubscribePlanError extends SubscribePlanState {
  final String message;

  const SubscribePlanError(this.message);

  @override
  List<Object> get props => [message];
}
