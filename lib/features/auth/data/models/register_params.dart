class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final int cityId;
  final String phoneCode;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.cityId,
    required this.phoneCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'city_id': cityId,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'phone_code': phoneCode,
  };
}
