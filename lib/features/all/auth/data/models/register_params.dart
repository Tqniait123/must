class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  RegisterParams(
      {required this.name,
      required this.email,
      required this.phone,
      required this.password,
      required this.passwordConfirmation});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
