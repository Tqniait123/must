import 'package:intl/intl.dart';

enum UserType { user, parkingMan }

class AppUser {
  final int id;
  final String name;
  final String? photo;
  final String email;
  final bool hasSubscription;
  final String? address;
  final String linkId;
  final bool? isOnline;
  final bool? isActivated;
  final String? phoneNumber;
  final UserType type;
  final List<Car> cars;
  final int points;

  // Added new fields
  final int? countryId;
  final int? governorateId;
  final int? cityId;
  final bool inParking;
  final DateTime? inParkingFrom;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    this.hasSubscription = false,
    this.address,
    required this.linkId,
    this.isOnline = false,
    this.phoneNumber,
    required this.type,
    required this.cars,
    this.isActivated = false,
    this.points = 0,
    this.countryId,
    this.governorateId,
    this.cityId,
    this.inParking = false,
    this.inParkingFrom,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      address: json['address'],
      linkId: json['link_id'],
      isOnline: json['is_online'],
      phoneNumber: json['phone_number'],
      type: json['type'] == 'user' ? UserType.user : UserType.parkingMan,
      cars: (json['cars'] as List<dynamic>?)?.map((car) => Car.fromJson(car)).toList() ?? [],
      isActivated: json['is_activated'],
      points: json['points'],
      countryId: json['country_id'],
      governorateId: json['governorate_id'],
      cityId: json['city_id'],
      inParking: json['in_parking'] ?? false,
      inParkingFrom: json['in_parking_from'] != null ? DateTime.parse(json['in_parking_from']) : null,
    );
  }
}

class Car {
  final String id;
  final String name; // Changed from model to name
  final String metalPlate; // Changed from plateNumber to metalPlate
  final String manufactureYear;
  final String licenseExpiryDate;
  final String? carPhoto;
  final String? frontLicense;
  final String? backLicense;
  final String? color;

  const Car({
    required this.id,
    required this.name,
    required this.metalPlate,
    required this.manufactureYear,
    required this.licenseExpiryDate,
    this.carPhoto,
    this.frontLicense,
    this.backLicense,
    this.color,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      metalPlate: json['metal plate'] ?? '',
      manufactureYear: json['manufacture year'] ?? '',
      licenseExpiryDate: json['license']['expiry date'] ?? '',
      carPhoto: json['car photo'],
      frontLicense: json['license']['front'],
      backLicense: json['license']['back'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'metal_plate': metalPlate,
      'manufacture_year': manufactureYear,
      'license_expiry_date': licenseExpiryDate,
      'car_photo': carPhoto,
      'front_license': frontLicense,
      'back_license': backLicense,
      'color': color,
    };
  }
}

/// Document model for national ID and driving license
class Document {
  final String? front;
  final String? back;

  const Document({this.front, this.back});

  Document copyWith({String? front, String? back}) {
    return Document(front: front ?? this.front, back: back ?? this.back);
  }

  factory Document.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Document();
    return Document(front: json['front'], back: json['back']);
  }

  Map<String, dynamic> toJson() {
    return {'front': front, 'back': back};
  }
}

/// Updated User model
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int? countryId;
  final int? governorateId;
  final int? cityId;
  final String? image;
  final Document? nationalId;
  final Document? drivingLicense;
  final int points;
  final bool inParking;
  final DateTime? inParkingFrom;
  final bool? approved;
  final bool? verified;

  const User._({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.countryId,
    this.governorateId,
    this.cityId,
    this.image,
    this.nationalId,
    this.drivingLicense,
    required this.points,
    this.inParking = false,
    this.inParkingFrom,
    this.approved,
    this.verified,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    int? countryId,
    int? governorateId,
    int? cityId,
    String? image,
    Document? nationalId,
    Document? drivingLicense,
    int? points,
    bool? inParking,
    DateTime? inParkingFrom,
    bool? approved,
    bool? verified,
  }) {
    return User._(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryId: countryId ?? this.countryId,
      governorateId: governorateId ?? this.governorateId,
      cityId: cityId ?? this.cityId,
      image: image ?? this.image,
      nationalId: nationalId ?? this.nationalId,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      points: points ?? this.points,
      inParking: inParking ?? this.inParking,
      inParkingFrom: inParkingFrom ?? this.inParkingFrom,
      approved: approved ?? this.approved,
      verified: verified ?? this.verified,
    );
  }

  /// Parse custom date format: "12-08-2025 08:48 AM"
  static DateTime? _parseCustomDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Define the format that matches your API response
      final formatter = DateFormat('dd-MM-yyyy hh:mm a', 'en_US');
      return formatter.parse(dateString);
    } catch (e) {
      // Fallback to ISO format parsing if custom format fails
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print('Error parsing date: $dateString - $e');
        return null;
      }
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User._(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      countryId: json['country_id'],
      governorateId: json['governorate_id'],
      cityId: json['city_id'],
      image: json['image'],
      nationalId: json['national_id'] != null ? Document.fromJson(json['national_id']) : null,
      drivingLicense: json['driving_license'] != null ? Document.fromJson(json['driving_license']) : null,
      points: json['points'] ?? 0,
      inParking: json['in_parking'] ?? false,
      inParkingFrom: _parseCustomDateTime(json['in_parking_from']),
      approved: json['approved'] != null ? json['approved'] == 1 : null,
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country_id': countryId,
      'governorate_id': governorateId,
      'city_id': cityId,
      'image': image,
      'national_id': nationalId?.toJson(),
      'driving_license': drivingLicense?.toJson(),
      'points': points,
      'in_parking': inParking,
      'in_parking_from': inParkingFrom?.toIso8601String(),
      'approved': approved != null ? (approved! ? 1 : 0) : null,
      'verified': verified,
    };
  }
}

/// Points record model
class PointsRecord {
  final String parking;
  final int points;
  final int equivalentMoney;
  final String status;
  final String date;

  PointsRecord({
    required this.parking,
    required this.points,
    required this.equivalentMoney,
    required this.status,
    required this.date,
  });

  factory PointsRecord.fromJson(Map<String, dynamic> json) {
    return PointsRecord(
      parking: json['parking'] ?? '',
      points: json['points'] ?? 0,
      equivalentMoney: json['equivalent money'] ?? 0,
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'parking': parking, 'points': points, 'equivalent money': equivalentMoney, 'status': status, 'date': date};
  }
}

/// User data wrapper
class UserData {
  final User user;
  final String accessToken;

  UserData({required this.user, required this.accessToken});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(user: User.fromJson(json['user']), accessToken: json['access_token'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'access_token': accessToken};
  }
}
