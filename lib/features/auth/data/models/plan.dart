class SubscriptionPlan {
  final int id;
  final String name;
  final double? price;
  final int? durationDays; // Changed to int
  final String? features; // Added new field
  final String? photo; // Added new field

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.price,
    this.durationDays, // Updated constructor
    this.features, // Updated constructor
    this.photo, // Updated constructor
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : null,
      durationDays: json['duration_days'] as int?,
      features: json['features'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'duration_days': durationDays, // Updated to match JSON structure
        'features': features, // Added new field
        'photo': photo, // Added new field
      };
}
