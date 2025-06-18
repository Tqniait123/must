import 'package:must_invest/features/auth/data/models/user.dart';

class AuthModel {
  final User user;
  final String? token;

  AuthModel({required this.user, this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: User.fromJson(json['user']),
      token: json['access_token'],
      // hasSubscription: json['has_subscription'],
    );
  }
}
