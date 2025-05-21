// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part "response.g.dart";
part 'response_codes.dart';

@JsonSerializable(
  genericArgumentFactories: true,
  createToJson: false,
  createFactory: false,
)
sealed class ApiResponse<T> {
  final bool status; // Updated to reflect the new structure
  final String message; // New field for the message

  ApiResponse({required this.status, required this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    if (json["status"] == true) {
      if (json.containsKey("token")) {
        return TokenResponse<T>.fromJson(json, fromJsonT);
      } else {
        return SuccessResponse<T>.fromJson(json, fromJsonT);
      }
    } else {
      if (json["code"] == ResponseCode.BAD_INPUT.name) {
        return BadInputResponse<T>.fromJson(json);
      } else {
        return ErrorResponse<T>.fromJson(json);
      }
    }
  }
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class SuccessResponse<T> extends ApiResponse<T> {
  final T data; // Updated to match the new "data" key
  SuccessResponse({
    required super.status,
    required super.message,
    required this.data,
  });

  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$SuccessResponseFromJson(json, fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class TokenResponse<T> extends SuccessResponse<T> {
  final String token;

  TokenResponse({
    required super.status,
    required super.message,
    required super.data,
    required this.token,
  });

  factory TokenResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$TokenResponseFromJson(json, fromJsonT);
}

@JsonSerializable(createToJson: false)
class ErrorResponse<T> extends ApiResponse<T> {
  ErrorResponse({required super.status, required super.message, });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadInputResponse<T> extends ErrorResponse<T> {
  @JsonKey(name: "Errors")
  final Map<String, ResponseCode> errors;

  BadInputResponse({
    required this.errors,
    required super.status,
    required super.message,
  }) : super();

  factory BadInputResponse.fromJson(Map<String, dynamic> json) =>
      _$BadInputResponseFromJson(json);
}