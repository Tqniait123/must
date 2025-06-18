class VerifyParams {
  final String phone;
  final String loginCode;
  final String? codeKey;

  VerifyParams({required this.phone, required this.loginCode, this.codeKey});

  Map<String, dynamic> toJson() => {
    'phone': phone,
    codeKey ?? 'login_code': loginCode,
  };
}
