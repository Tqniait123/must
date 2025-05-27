class LoginWithGoogleParams {
  final String email;
  final String displayName;
  final String photoUrl;
  final String id;
  final String? deviceToken;

  LoginWithGoogleParams(
      {required this.email,
      required this.displayName,
      required this.deviceToken,
      required this.id,
      required this.photoUrl});

  Map<String, dynamic> toJson(String? deviceToken) => {
        'email': email,
        'name': displayName,
        'photoUrl': photoUrl,
        'google_id': id,
        'device_token': deviceToken ?? this.deviceToken,
      };
}
