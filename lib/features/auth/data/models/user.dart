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

/// User model for the example
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? image;
  final List<PointsRecord> points;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      points:
          json['points'] is List ? (json['points'] as List).map((point) => PointsRecord.fromJson(point)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'points': points.map((point) => point.toJson()).toList(),
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
