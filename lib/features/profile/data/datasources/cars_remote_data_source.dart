import 'dart:io';

import 'package:dio/dio.dart';
import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

abstract class CarRemoteDataSource {
  Future<ApiResponse<List<Car>>> getMyCars(String token);
  Future<ApiResponse<Car>> getCarDetails(String token, String carId);
  Future<ApiResponse<Car>> addCar(String token, AddCarRequest request);
  Future<ApiResponse<Car>> updateCar(String token, String carId, UpdateCarRequest request);
  Future<ApiResponse<void>> deleteCar(String token, String carId);
}

class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final DioClient dioClient;

  CarRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<List<Car>>> getMyCars(String token) async {
    return dioClient.request<List<Car>>(
      method: RequestMethod.get,
      EndPoints.cars,
      options: token.toAuthorizationOptions(),
      fromJson: (json) => List<Car>.from((json as List).map((car) => Car.fromJson(car as Map<String, dynamic>))),
    );
  }

  @override
  Future<ApiResponse<Car>> getCarDetails(String token, String carId) async {
    return dioClient.request<Car>(
      method: RequestMethod.get,
      '${EndPoints.cars}/$carId',
      options: token.toAuthorizationOptions(),
      fromJson: (json) => Car.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<Car>> addCar(String token, AddCarRequest request) async {
    return dioClient.request<Car>(
      method: RequestMethod.post,
      EndPoints.addCar,
      options: token.toAuthorizationOptions(),
      data: await request.toFormData(),
      contentType: ContentType.formData,
      fromJson: (json) => Car.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<Car>> updateCar(String token, String carId, UpdateCarRequest request) async {
    return dioClient.request<Car>(
      method: RequestMethod.post,
      '${EndPoints.updateCar}/$carId',
      options: token.toAuthorizationOptions(),
      data: await request.toFormData(),
      contentType: ContentType.formData,
      fromJson: (json) => Car.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> deleteCar(String token, String carId) async {
    return dioClient.request<void>(
      method: RequestMethod.get,
      '${EndPoints.deleteCar}/$carId',
      options: token.toAuthorizationOptions(),
      fromJson: (json) {},
    );
  }
}

class AddCarRequest {
  final String name;
  final File carPhoto;
  final File frontLicense;
  final File backLicense;
  final String metalPlate;
  final String manufactureYear;
  final String licenseExpiryDate;
  final String color;

  const AddCarRequest({
    required this.name,
    required this.carPhoto,
    required this.frontLicense,
    required this.backLicense,
    required this.metalPlate,
    required this.manufactureYear,
    required this.licenseExpiryDate,
    required this.color,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'car_photo': await MultipartFile.fromFile(carPhoto.path, filename: 'car_photo.${carPhoto.path.split('.').last}'),
      'front_license': await MultipartFile.fromFile(
        frontLicense.path,
        filename: 'front_license.${frontLicense.path.split('.').last}',
      ),
      'back_license': await MultipartFile.fromFile(
        backLicense.path,
        filename: 'back_license.${backLicense.path.split('.').last}',
      ),
      'metal_plate': metalPlate,
      'manufacture_year': manufactureYear,
      'license_expiry_date': licenseExpiryDate,
      'color': color,
    });
  }
}

class UpdateCarRequest {
  final String name;
  final File? carPhoto;
  final File? frontLicense;
  final File? backLicense;
  final String metalPlate;
  final String manufactureYear;
  final String licenseExpiryDate;
  final String color;

  const UpdateCarRequest({
    required this.name,
    this.carPhoto,
    this.frontLicense,
    this.backLicense,
    required this.metalPlate,
    required this.manufactureYear,
    required this.licenseExpiryDate,
    required this.color,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'name': name,
      'metal_plate': metalPlate,
      'manufacture_year': manufactureYear,
      'license_expiry_date': licenseExpiryDate,
      'color': color,
    };

    // Only add files if they are provided (for updates)
    if (carPhoto != null) {
      data['car_photo'] = await MultipartFile.fromFile(
        carPhoto!.path,
        filename: 'car_photo.${carPhoto!.path.split('.').last}',
      );
    }
    if (frontLicense != null) {
      data['front_license'] = await MultipartFile.fromFile(
        frontLicense!.path,
        filename: 'front_license.${frontLicense!.path.split('.').last}',
      );
    }
    if (backLicense != null) {
      data['back_license'] = await MultipartFile.fromFile(
        backLicense!.path,
        filename: 'back_license.${backLicense!.path.split('.').last}',
      );
    }

    return FormData.fromMap(data);
  }
}
