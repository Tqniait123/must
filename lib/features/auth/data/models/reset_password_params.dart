class ResetPasswordParams {
  final String phone;
  final String password;
  final String confirmPassword;

  ResetPasswordParams({
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
    'password_confirmation': confirmPassword,
  };
}
