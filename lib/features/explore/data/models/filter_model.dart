enum SortBy {
  nearest,
  mostPopular,
  mostWanted;

  static SortBy? fromJson(Map<String, dynamic> json) {
    final mostPopular = json['most_popular']?.toString() == "1";
    final mostWanted = json['most_wanted']?.toString() == "1";

    if (mostPopular) return SortBy.mostPopular;
    if (mostWanted) return SortBy.mostWanted;
    if (json.containsKey('most_popular') || json.containsKey('most_wanted')) {
      return SortBy.nearest; // Only return nearest if sorting keys exist
    }
    return null; // No sorting specified
  }

  Map<String, String> toJson() {
    switch (this) {
      case SortBy.mostPopular:
        return {'most_popular': '1', 'most_wanted': '0'};
      case SortBy.mostWanted:
        return {'most_popular': '0', 'most_wanted': '1'};
      case SortBy.nearest:
        return {'most_popular': '0', 'most_wanted': '0'};
    }
  }
}

class FilterModel {
  final SortBy? sortBy;
  final double? lat;
  final double? lng;
  final bool byUserCity;

  FilterModel({
    this.sortBy,
    this.lat,
    this.lng,
    this.byUserCity = false,
  }) : assert(
          sortBy != SortBy.nearest || (lat != null && lng != null),
          'lat and lng must be provided when sortBy is nearest',
        );

  // Convert from JSON
  factory FilterModel.fromJson(Map<String, dynamic> json) {
    final sortBy = SortBy.fromJson(json);
    final lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    final lng = json['lng'] != null ? double.tryParse(json['lng'].toString()) : null;

    return FilterModel(
      sortBy: sortBy,
      lat: lat,
      lng: lng,
      byUserCity: json['by_user_city'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'by_user_city': byUserCity,
    };

    if (sortBy != null) {
      result.addAll(sortBy!.toJson());
    }

    if (lat != null) result['lat'] = lat;
    if (lng != null) result['lng'] = lng;

    return result;
  }

  // Create a copy with updated values
  FilterModel copyWith({
    SortBy? sortBy,
    double? lat,
    double? lng,
    bool? byUserCity,
  }) {
    return FilterModel(
      sortBy: sortBy ?? this.sortBy,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      byUserCity: byUserCity ?? this.byUserCity,
    );
  }

  // Helper method to create nearest filter with required coordinates
  factory FilterModel.nearest({
    required double lat,
    required double lng,
    bool byUserCity = false,
  }) {
    return FilterModel(
      sortBy: SortBy.nearest,
      lat: lat,
      lng: lng,
      byUserCity: byUserCity,
    );
  }

  // Helper methods to create other filters without coordinates
  factory FilterModel.mostPopular({bool byUserCity = false}) {
    return FilterModel(
      sortBy: SortBy.mostPopular,
      byUserCity: byUserCity,
    );
  }

  factory FilterModel.mostWanted({bool byUserCity = false}) {
    return FilterModel(
      sortBy: SortBy.mostWanted,
      byUserCity: byUserCity,
    );
  }

  // Helper method to create filter with just byUserCity
  factory FilterModel.byUserCity() {
    return FilterModel(byUserCity: true);
  }
}
