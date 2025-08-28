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
}
