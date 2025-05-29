class PaymentRequestModel {
  final String requesterName;
  final String parkingName;
  final String location;
  final double amount;
  final int pointsEquivalent;

  PaymentRequestModel({
    required this.requesterName,
    required this.parkingName,
    required this.location,
    required this.amount,
    required this.pointsEquivalent,
  });
}
