class Country {
  final String name;
  final String countryCode;

  Country({required this.name, required this.countryCode});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      countryCode: json['country_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'country_code': countryCode};
  }
}
