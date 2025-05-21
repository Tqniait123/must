class EndPoints {
  const EndPoints._();

  // Authentication Endpoints
  static const String baseUrl = 'https://3eshplus.dev2.tqnia.me/api/';
  static const String login = 'login';
  static const String loginWithGoogle = 'auth/google/callback';
  static const String loginWithApple = 'login/apple';
  static const String autoLogin = 'profile';
  static const String register = 'register';
  static const String plans = 'subscriptions';
  static String subscribePlan(int planId) => 'subscribe';
  static String planBrands(int planId) => 'subscriptions/$planId/vendors';
  static const String forgetPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String categories = 'categories';
  static const String search = 'vendors/search';
  static const String discount = 'discounts/create';
  static const String home = 'home';
  static const String homeGuest = 'guestHome';
  static const String filter = 'vendors/getFilter';
  static String page(String page) => 'static-pages/$page';
  static const String createTicket = 'tickets';
  static const String getTickets = 'tickets';
  static String showTicket(int id) => 'tickets/$id';
  static String replyTicket(int id) => 'tickets/$id/reply';
  static const String mySubscriptions = 'my-subscriptions';
  static const String notifications = 'orders';
  static String vendor(int id) => 'vendors/$id/show';
  static const String approveOrder = 'orders/accept';
  static const String declineOrder = 'orders/decline';
  static const String offers = 'vendors/categoriesWithVendors';
  static const String updateLocation = 'updateLatAndLon';
  static const String nearbyVendors = 'nearby/Vendors';
  static String cardTransactions(String cardNumber) =>
      'getMySubscriptionsWithDiscounts/$cardNumber';
  static const String ad = 'popups/Vendors';
}
