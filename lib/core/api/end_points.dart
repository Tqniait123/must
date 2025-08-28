class EndPoints {
  const EndPoints._();

  // Authentication Endpoints
  static const String baseUrl = 'https://must.dev2.tqnia.me/api/';
  static const String login = 'login';
  static const String loginWithGoogle = 'social/login';
  static const String loginWithApple = 'login/apple';
  static const String autoLogin = 'profile';
  static const String register = 'register';
  static const String verifyRegistration = 'register/verify_phone';
  static const String verifyPasswordReset = 'check_reset_code';
  static const String resendOtp = 'resend_otp';
  static const String forgetPassword = 'forgot_password';
  static const String resetPassword = 'reset_password';
  static const String updateProfile = 'update_profile';
  static const String home = 'home';
  static const String countries = 'countries';
  static String governorates(int id) => 'governorates/$id';
  static String cities(int id) => 'cities/$id';
  static const String parking = 'parking';
  static const String parkingInUserCity = 'parking_in_user_city';
  static const String notifications = 'notifications';
  static const String faqs = 'faqs';
  static String aboutUs(String lang) => 'about_us';
  static String terms(String lang) => 'terms';
  static String privacyPolicy(String lang) => 'privacy_policy';
  static const String contactUs = 'contact_info';
  static const String cars = 'cars';
  static const String addCar = 'cars/store';
  static const String updateCar = 'cars/update';
  static const String deleteCar = 'cars/delete';
  static const String chargePoints = 'points/charge';
  static String parkingPointsWithdrawn(int id) => '/parking/$id/points_withdrawn';
  static const String history = 'history';
  static const String startParking = 'parking/start';
  static const String offers = 'offers';
  static const String deleteAccount = 'delete_account';
  static const String appSettings = 'app_settings';
  static const String buyOffer = 'buy_offer';
  
}
