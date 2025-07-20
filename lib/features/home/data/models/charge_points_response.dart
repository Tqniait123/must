class ChargePointsResponse {
  final int points;
  final String lastUpdated;

  ChargePointsResponse({required this.points, required this.lastUpdated});

  factory ChargePointsResponse.fromJson(Map<String, dynamic> json) {
    return ChargePointsResponse(points: json['points'] ?? 0, lastUpdated: json['last_updated'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'points': points, 'last_updated': lastUpdated};
  }

  @override
  String toString() {
    return 'ChargePointsResponse{points: $points, lastUpdated: $lastUpdated}';
  }
}
