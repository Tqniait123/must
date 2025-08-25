// offers/data/models/offer.dart
import 'package:intl/intl.dart';

class Offer {
  final int id;
  final String name;
  final int points;
  final double price;
  final String brief;
  final DateTime startAt;
  final DateTime expiredAt;

  Offer({
    required this.id,
    required this.name,
    required this.points,
    required this.price,
    required this.brief,
    required this.startAt,
    required this.expiredAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      name: json['name'] as String,
      points: json['points'] as int,
      price: (json['price'] as num).toDouble(),
      brief: json['brief'] as String,
      startAt: _parseDate(json['start_at'] as String),
      expiredAt: _parseDate(json['expired_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'price': price,
      'brief': brief,
      'start_at': _formatDateForApi(startAt),
      'expired_at': _formatDateForApi(expiredAt),
    };
  }

  /// Parse date string using multiple format attempts for better API compatibility
  static DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) {
      throw ArgumentError('Date string cannot be empty');
    }

    // List of possible date formats to try (most common first)
    final formats = [
      'yyyy-MM-dd HH:mm:ss', // Standard SQL datetime
      'yyyy-MM-ddTHH:mm:ss.SSSZ', // ISO 8601 with milliseconds and timezone
      'yyyy-MM-ddTHH:mm:ssZ', // ISO 8601 with timezone
      'yyyy-MM-ddTHH:mm:ss', // ISO 8601 without timezone
      'yyyy-MM-dd hh:mm a', // 12-hour format with AM/PM (your failing case)
      'yyyy-MM-dd h:mm a', // 12-hour format with AM/PM (single digit hour)
      'yyyy-MM-dd HH:mm', // 24-hour format without seconds
      'dd/MM/yyyy HH:mm:ss', // European format
      'dd/MM/yyyy hh:mm a', // European format with AM/PM
      'MM/dd/yyyy HH:mm:ss', // US format
      'MM/dd/yyyy hh:mm a', // US format with AM/PM
      'yyyy/MM/dd HH:mm:ss', // Alternative format
      'yyyy-MM-dd', // Date only
    ];

    // Try parsing with each format
    for (String format in formats) {
      try {
        final formatter = DateFormat(format, 'en_US');
        return formatter.parse(dateString);
      } catch (e) {
        // Continue to next format
        continue;
      }
    }

    // If all specific formats fail, try DateTime.parse() as last resort
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // If everything fails, throw a descriptive error
      throw FormatException(
        'Unable to parse date: "$dateString". Supported formats include: yyyy-MM-dd HH:mm:ss, yyyy-MM-dd hh:mm a, ISO 8601, etc.',
      );
    }
  }

  /// Format DateTime for API requests (keeping it consistent)
  static String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(date);
  }

  // Convenience getters for date operations
  bool get isExpired => DateTime.now().isAfter(expiredAt);
  bool get isActive => DateTime.now().isBefore(expiredAt) && DateTime.now().isAfter(startAt);
  bool get isUpcoming => DateTime.now().isBefore(startAt);

  bool get isExpiringSoon {
    final now = DateTime.now();
    final difference = expiredAt.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

  Duration get timeUntilExpiry => expiredAt.difference(DateTime.now());
  Duration get timeSinceStart => DateTime.now().difference(startAt);

  @override
  String toString() {
    return 'Offer{id: $id, name: $name, points: $points, price: $price, brief: $brief, startAt: $startAt, expiredAt: $expiredAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Offer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// offers/data/models/offer_filter_model.dart
enum OfferSortBy {
  all,
  highestPoints,
  lowestPrice,
  newest,
  expiringSoon;

  Map<String, String> toJson() {
    switch (this) {
      case OfferSortBy.all:
        return {};
      case OfferSortBy.highestPoints:
        return {'sort_by': 'points', 'order': 'desc'};
      case OfferSortBy.lowestPrice:
        return {'sort_by': 'price', 'order': 'asc'};
      case OfferSortBy.newest:
        return {'sort_by': 'start_at', 'order': 'desc'};
      case OfferSortBy.expiringSoon:
        return {'sort_by': 'expired_at', 'order': 'asc'};
    }
  }

  static OfferSortBy? fromJson(Map<String, dynamic> json) {
    final sortBy = json['sort_by'];
    final order = json['order'];

    if (sortBy == 'points' && order == 'desc') return OfferSortBy.highestPoints;
    if (sortBy == 'price' && order == 'asc') return OfferSortBy.lowestPrice;
    if (sortBy == 'start_at' && order == 'desc') return OfferSortBy.newest;
    if (sortBy == 'expired_at' && order == 'asc') return OfferSortBy.expiringSoon;

    return OfferSortBy.all;
  }
}

class OfferFilterModel {
  final OfferSortBy? sortBy;
  final int? minPoints;
  final int? maxPoints;
  final double? minPrice;
  final double? maxPrice;
  final String? name;
  final bool activeOnly;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? expiredDateFrom;
  final DateTime? expiredDateTo;

  OfferFilterModel({
    this.sortBy,
    this.minPoints,
    this.maxPoints,
    this.minPrice,
    this.maxPrice,
    this.name,
    this.activeOnly = true,
    this.startDateFrom,
    this.startDateTo,
    this.expiredDateFrom,
    this.expiredDateTo,
  });

  // Convert from JSON
  factory OfferFilterModel.fromJson(Map<String, dynamic> json) {
    final sortBy = OfferSortBy.fromJson(json);

    return OfferFilterModel(
      sortBy: sortBy,
      minPoints: json['min_points'] != null ? int.tryParse(json['min_points'].toString()) : null,
      maxPoints: json['max_points'] != null ? int.tryParse(json['max_points'].toString()) : null,
      minPrice: json['min_price'] != null ? double.tryParse(json['min_price'].toString()) : null,
      maxPrice: json['max_price'] != null ? double.tryParse(json['max_price'].toString()) : null,
      name: json['name'],
      activeOnly: json['active_only'] ?? true,
      startDateFrom: json['start_date_from'] != null ? _parseFilterDate(json['start_date_from']) : null,
      startDateTo: json['start_date_to'] != null ? _parseFilterDate(json['start_date_to']) : null,
      expiredDateFrom: json['expired_date_from'] != null ? _parseFilterDate(json['expired_date_from']) : null,
      expiredDateTo: json['expired_date_to'] != null ? _parseFilterDate(json['expired_date_to']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {'active_only': activeOnly};

    if (sortBy != null) {
      result.addAll(sortBy!.toJson());
    }

    if (minPoints != null) result['min_points'] = minPoints;
    if (maxPoints != null) result['max_points'] = maxPoints;
    if (minPrice != null) result['min_price'] = minPrice;
    if (maxPrice != null) result['max_price'] = maxPrice;
    if (name != null) result['name'] = name;
    if (startDateFrom != null) result['start_date_from'] = _formatFilterDate(startDateFrom!);
    if (startDateTo != null) result['start_date_to'] = _formatFilterDate(startDateTo!);
    if (expiredDateFrom != null) result['expired_date_from'] = _formatFilterDate(expiredDateFrom!);
    if (expiredDateTo != null) result['expired_date_to'] = _formatFilterDate(expiredDateTo!);

    return result;
  }

  // Helper method to parse filter dates
  static DateTime? _parseFilterDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String) {
        return Offer._parseDate(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  // Helper method to format filter dates for API
  static String _formatFilterDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  // Create a copy with updated values
  OfferFilterModel copyWith({
    OfferSortBy? sortBy,
    int? minPoints,
    int? maxPoints,
    double? minPrice,
    double? maxPrice,
    String? name,
    bool? activeOnly,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? expiredDateFrom,
    DateTime? expiredDateTo,
  }) {
    return OfferFilterModel(
      sortBy: sortBy ?? this.sortBy,
      minPoints: minPoints ?? this.minPoints,
      maxPoints: maxPoints ?? this.maxPoints,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      name: name ?? this.name,
      activeOnly: activeOnly ?? this.activeOnly,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      expiredDateFrom: expiredDateFrom ?? this.expiredDateFrom,
      expiredDateTo: expiredDateTo ?? this.expiredDateTo,
    );
  }

  // Helper factory methods
  factory OfferFilterModel.all({bool activeOnly = true}) {
    return OfferFilterModel(sortBy: OfferSortBy.all, activeOnly: activeOnly);
  }

  factory OfferFilterModel.highestPoints({bool activeOnly = true}) {
    return OfferFilterModel(sortBy: OfferSortBy.highestPoints, activeOnly: activeOnly);
  }

  factory OfferFilterModel.lowestPrice({bool activeOnly = true}) {
    return OfferFilterModel(sortBy: OfferSortBy.lowestPrice, activeOnly: activeOnly);
  }

  factory OfferFilterModel.newest({bool activeOnly = true}) {
    return OfferFilterModel(sortBy: OfferSortBy.newest, activeOnly: activeOnly);
  }

  factory OfferFilterModel.expiringSoon({bool activeOnly = true}) {
    return OfferFilterModel(sortBy: OfferSortBy.expiringSoon, activeOnly: activeOnly);
  }

  factory OfferFilterModel.withName(String name, {bool activeOnly = true}) {
    return OfferFilterModel(name: name, activeOnly: activeOnly);
  }

  factory OfferFilterModel.byPointsRange({required int minPoints, required int maxPoints, bool activeOnly = true}) {
    return OfferFilterModel(minPoints: minPoints, maxPoints: maxPoints, activeOnly: activeOnly);
  }

  factory OfferFilterModel.byPriceRange({required double minPrice, required double maxPrice, bool activeOnly = true}) {
    return OfferFilterModel(minPrice: minPrice, maxPrice: maxPrice, activeOnly: activeOnly);
  }

  factory OfferFilterModel.byDateRange({
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? expiredDateFrom,
    DateTime? expiredDateTo,
    bool activeOnly = true,
  }) {
    return OfferFilterModel(
      startDateFrom: startDateFrom,
      startDateTo: startDateTo,
      expiredDateFrom: expiredDateFrom,
      expiredDateTo: expiredDateTo,
      activeOnly: activeOnly,
    );
  }

  // Convenience getters
  bool get hasPointsFilter => minPoints != null || maxPoints != null;
  bool get hasPriceFilter => minPrice != null || maxPrice != null;
  bool get hasNameFilter => name != null && name!.isNotEmpty;
  bool get hasDateFilter =>
      startDateFrom != null || startDateTo != null || expiredDateFrom != null || expiredDateTo != null;
  bool get hasAnyFilter =>
      hasPointsFilter || hasPriceFilter || hasNameFilter || hasDateFilter || sortBy != OfferSortBy.all;

  @override
  String toString() {
    return 'OfferFilterModel{sortBy: $sortBy, minPoints: $minPoints, maxPoints: $maxPoints, minPrice: $minPrice, maxPrice: $maxPrice, name: $name, activeOnly: $activeOnly, startDateFrom: $startDateFrom, startDateTo: $startDateTo, expiredDateFrom: $expiredDateFrom, expiredDateTo: $expiredDateTo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfferFilterModel &&
        other.sortBy == sortBy &&
        other.minPoints == minPoints &&
        other.maxPoints == maxPoints &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.name == name &&
        other.activeOnly == activeOnly &&
        other.startDateFrom == startDateFrom &&
        other.startDateTo == startDateTo &&
        other.expiredDateFrom == expiredDateFrom &&
        other.expiredDateTo == expiredDateTo;
  }

  @override
  int get hashCode {
    return Object.hash(
      sortBy,
      minPoints,
      maxPoints,
      minPrice,
      maxPrice,
      name,
      activeOnly,
      startDateFrom,
      startDateTo,
      expiredDateFrom,
      expiredDateTo,
    );
  }
}
