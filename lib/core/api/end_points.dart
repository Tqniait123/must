class EndPoints {
  const EndPoints._();

  // Authentication Endpoints
  static const String baseUrl = 'https://must.dev2.tqnia.me/api/';
  static const String login = 'login';
  static const String loginWithGoogle = 'auth/google/callback';
  static const String loginWithApple = 'login/apple';
  static const String autoLogin = 'profile';
  static const String register = 'register';
  static const String verifyRegistration = 'register/verify_phone';
  static const String verifyPasswordReset = 'check_reset_code';
  static const String resendOtp = 'resend_otp';
  static const String forgetPassword = 'forgot_password';
  static const String resetPassword = 'reset_password';
  static const String home = 'home';
  static const String countries = 'countries';
  static String governorates(int id) => 'governorates/$id';
  static String cities(int id) => 'cities/$id';
  static const String parking = 'parking';
  static const String parkingInUserCity = 'parking_in_user_city';
}
