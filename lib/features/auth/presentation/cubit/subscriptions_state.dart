part of 'subscriptions_cubit.dart';

sealed class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object> get props => [];
}

final class SubscriptionsInitial extends SubscriptionsState {}

final class SubscriptionsLoading extends SubscriptionsState {}

final class SubscriptionsSuccess extends SubscriptionsState {
  final List<SubscriptionPlan> plans;

  const SubscriptionsSuccess(this.plans);

  @override
  List<Object> get props => [plans];
}

final class SubscriptionsError extends SubscriptionsState {
  final String message;

  const SubscriptionsError(this.message);

  @override
  List<Object> get props => [message];
}
