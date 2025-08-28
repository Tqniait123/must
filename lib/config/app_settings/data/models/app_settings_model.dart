class AppSettings {
  final int pointsEqualMoney;
  final int lessParkingPeriod;

  AppSettings({required this.pointsEqualMoney, required this.lessParkingPeriod});

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pointsEqualMoney: json['points_equal_money'] ?? 1,
      lessParkingPeriod: json['less_parking_period'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {'points_equal_money': pointsEqualMoney, 'less_parking_period': lessParkingPeriod};
  }

  AppSettings copyWith({int? pointsEqualMoney, int? lessParkingPeriod}) {
    return AppSettings(
      pointsEqualMoney: pointsEqualMoney ?? this.pointsEqualMoney,
      lessParkingPeriod: lessParkingPeriod ?? this.lessParkingPeriod,
    );
  }

  // Helper functions in Model

  /// Converts money amount to points
  /// Example: If pointsEqualMoney = 10 and moneyAmount = 5.0
  /// Result: 50 points (5.0 * 10)
  int convertMoneyToPoints(double moneyAmount) {
    return (moneyAmount * pointsEqualMoney).round();
  }

  /// Converts points to money amount
  /// Example: If pointsEqualMoney = 10 and points = 50
  /// Result: 5.0 money units (50 / 10)
  double convertPointsToMoney(int points) {
    if (pointsEqualMoney == 0) return 0.0;
    return points / pointsEqualMoney;
  }

  /// Calculates how many points needed for a specific money amount with precision
  int calculateExactPointsNeeded(double exactMoneyAmount) {
    return (exactMoneyAmount * pointsEqualMoney).ceil();
  }

  /// Calculates the money equivalent of points with precision
  double calculateExactMoneyValue(int points) {
    if (pointsEqualMoney == 0) return 0.0;
    return points.toDouble() / pointsEqualMoney;
  }

  /// Checks if user has enough points for a given money amount
  bool hasEnoughPoints(int availablePoints, double requiredMoneyAmount) {
    int requiredPoints = convertMoneyToPoints(requiredMoneyAmount);
    return availablePoints >= requiredPoints;
  }

  /// Calculates remaining points after a transaction
  int calculateRemainingPoints(int currentPoints, double spentMoneyAmount) {
    int pointsToDeduct = convertMoneyToPoints(spentMoneyAmount);
    return currentPoints - pointsToDeduct;
  }

  /// Calculates bonus points based on money spent (you can customize the logic)
  int calculateBonusPoints(double moneySpent, {double bonusRate = 0.1}) {
    double bonusAmount = moneySpent * bonusRate;
    return convertMoneyToPoints(bonusAmount);
  }

  /// Formats points display with money equivalent
  String formatPointsWithMoneyEquivalent(int points) {
    double moneyEquivalent = convertPointsToMoney(points);
    return '$points points (≈ \$${moneyEquivalent.toStringAsFixed(2)})';
  }

  /// Formats money display with points equivalent
  String formatMoneyWithPointsEquivalent(double money) {
    int pointsEquivalent = convertMoneyToPoints(money);
    return '\$${money.toStringAsFixed(2)} (≈ $pointsEquivalent points)';
  }

  /// Calculates discount in points for less parking period
  int calculateLessParkingDiscount(int originalPoints, {double discountRate = 0.1}) {
    return (originalPoints * discountRate).round();
  }

  /// Gets the exchange rate description
  String getExchangeRateDescription() {
    return '$pointsEqualMoney points = \$1.00';
  }
}
