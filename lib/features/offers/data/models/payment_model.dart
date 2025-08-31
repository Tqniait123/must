import 'package:equatable/equatable.dart';

class PaymentModel extends Equatable {
  final String status;
  final int? offerId;
  final String paymentUrl;

  const PaymentModel({required this.status, this.offerId, required this.paymentUrl});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      status: json['status'] as String,
      offerId: json['offer_id'] as int?,
      paymentUrl: json['payment_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'offer_id': offerId, 'payment_url': paymentUrl};
  }

  @override
  List<Object> get props => [status, paymentUrl];
}
