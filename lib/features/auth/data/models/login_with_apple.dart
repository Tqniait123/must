class LoginWithAppleParams {
  final String? email;
  final String? familyName;
  final String? givenName;
  final String identityToken;
  final String authorizationCode;
  final String? deviceToken;

  LoginWithAppleParams({
    this.email,
    this.familyName,
    this.givenName,
    required this.identityToken,
    required this.authorizationCode,
    this.deviceToken,
  });

  Map<String, dynamic> toJson(String? deviceToken) => {
        'email': email,
        'name': "$familyName $givenName",
        'identity_token': identityToken,
        'authorization_code': authorizationCode,
        'device_token': deviceToken ?? this.deviceToken,
      };
}
