import 'package:must_invest/features/auth/data/models/user.dart';

class AuthModel {
  final AppUser user;
  final String? token;
  final bool hasSubscription;

  AuthModel({required this.user, this.token, this.hasSubscription = false});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: AppUser.fromJson(json['user']),
      token: json['token'],
      // hasSubscription: json['has_subscription'],
    );
  }
}
