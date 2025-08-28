part of 'buy_offer_cubit.dart';

abstract class BuyOfferState extends Equatable {
  const BuyOfferState();

  @override
  List<Object> get props => [];
}

class BuyOfferInitial extends BuyOfferState {}

class BuyOfferLoading extends BuyOfferState {}

class BuyOfferSuccess extends BuyOfferState {
  final PaymentModel paymentModel;

  const BuyOfferSuccess(this.paymentModel);

  @override
  List<Object> get props => [paymentModel];
}

class BuyOfferError extends BuyOfferState {
  final String message;

  const BuyOfferError(this.message);

  @override
  List<Object> get props => [message];
}
