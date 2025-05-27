class LoginParams {
  final String email;
  final String password;
  final bool isRemembered;

  LoginParams({
    required this.email,
    required this.password,
    this.isRemembered = false,
  });

  Map<String, dynamic> toJson(String deviceToken) =>
      {'login': email, 'password': password, 'device_token': deviceToken};
}
