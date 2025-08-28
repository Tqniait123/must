class LoginWithGoogleParams {
  final String email;
  final String displayName;
  final String photoUrl;
  final String id;
  final String? deviceToken;

  LoginWithGoogleParams({
    required this.email,
    required this.displayName,
    required this.deviceToken,
    required this.id,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson(String? deviceToken) => {
    'email': email,
    'name': displayName,
    'image': photoUrl,
    'social_media_id': id,
    'device_token': deviceToken ?? this.deviceToken,
    'provider': 'google',
  };
}
