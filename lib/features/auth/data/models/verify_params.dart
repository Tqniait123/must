class VerifyParams {
  final String phone;
  final String loginCode;

  VerifyParams({required this.phone, required this.loginCode});

  Map<String, dynamic> toJson() => {'phone': phone, 'login_code': loginCode};
}
