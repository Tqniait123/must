
// offers_state.dart
part of 'offers_cubit.dart';

sealed class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object> get props => [];
}

final class OffersInitial extends OffersState {}

final class OffersLoading extends OffersState {}

final class OffersSuccess extends OffersState {
  final List<Offer> offers;

  const OffersSuccess(this.offers);

  @override
  List<Object> get props => [offers];
}

final class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object> get props => [message];
}

final class SingleOfferLoading extends OffersState {}

final class SingleOfferSuccess extends OffersState {
  final Offer offer;

  const SingleOfferSuccess(this.offer);

  @override
  List<Object> get props => [offer];
}

final class SingleOfferError extends OffersState {
  final String message;

  const SingleOfferError(this.message);

  @override
  List<Object> get props => [message];
}
