import 'package:must_invest/features/auth/data/models/user.dart';

class ParkingProcessModel {
  final Car car;
  final String employerId;

  ParkingProcessModel({required this.car, required this.employerId});

  Map<String, dynamic> toJson() {
    return {'car_id': car.id, 'employer_id': employerId};
  }
}
