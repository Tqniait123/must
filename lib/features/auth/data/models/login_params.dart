class LoginParams {
  final String phone;
  final String password;
  final bool isRemembered;

  LoginParams({
    required this.phone,
    required this.password,
    this.isRemembered = false,
  });

  Map<String, dynamic> toJson({String? deviceToken}) => {
    'phone': phone,
    'password': password,
    if (deviceToken != null) 'device_token': deviceToken,
  };
}
