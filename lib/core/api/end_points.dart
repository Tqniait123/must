class EndPoints {
  const EndPoints._();

  // Authentication Endpoints
  static const String baseUrl = 'https://must.dev2.tqnia.me/api/';
  static const String login = 'login';
  static const String loginWithGoogle = 'auth/google/callback';
  static const String loginWithApple = 'login/apple';
  static const String autoLogin = 'profile';
  static const String register = 'register';
  static const String forgetPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String home = 'home';
}
