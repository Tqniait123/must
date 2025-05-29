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
      cars:
          (json['cars'] as List<dynamic>?)
              ?.map((car) => Car.fromJson(car))
              .toList() ??
          [],
      isActivated: json['is_activated'],
    );
  }
}

// class User extends AppUser {
//   final List<Car> cars;

//   const User({
//     required super.id,
//     required super.name,
//     required super.email,
//     super.photo,
//     super.hasSubscription,
//     super.address,
//     required super.linkId,
//     super.isOnline,
//     super.phoneNumber,
//     this.cars = const [],
//   }) : super(type: UserType.user);

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       photo: json['photo'],
//       address: json['address'],
//       linkId: json['link_id'],
//       isOnline: json['is_online'],
//       phoneNumber: json['phone_number'],
//       cars:
//           (json['cars'] as List<dynamic>?)
//               ?.map((car) => Car.fromJson(car))
//               .toList() ??
//           [],
//     );
//   }
// }

// class ParkingMan extends AppUser {
//   const ParkingMan({
//     required super.id,
//     required super.name,
//     required super.email,
//     super.photo,
//     super.hasSubscription,
//     super.address,
//     required super.linkId,
//     super.isOnline,
//     super.phoneNumber,
//   }) : super(type: UserType.parkingMan);

//   factory ParkingMan.fromJson(Map<String, dynamic> json) {
//     return ParkingMan(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       photo: json['photo'],
//       address: json['address'],
//       linkId: json['link_id'],
//       isOnline: json['is_online'],
//       phoneNumber: json['phone_number'],
//     );
//   }
// }

class Car {
  final String id;
  final String model;
  final String plateNumber;

  const Car({required this.id, required this.model, required this.plateNumber});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      model: json['model'],
      plateNumber: json['plate_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'model': model, 'plate_number': plateNumber};
  }
}
