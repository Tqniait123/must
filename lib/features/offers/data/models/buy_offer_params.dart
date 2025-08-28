import 'package:equatable/equatable.dart';

class BuyOfferParams extends Equatable {
  final int offerId;

  const BuyOfferParams({
    required this.offerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
    };
  }

  @override
  List<Object> get props => [offerId];
}
