import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/all/auth/data/models/auth_model.dart';
import 'package:must_invest/features/all/auth/data/models/brands.dart';
import 'package:must_invest/features/all/auth/data/models/login_params.dart';
import 'package:must_invest/features/all/auth/data/models/login_with_apple.dart';
import 'package:must_invest/features/all/auth/data/models/login_with_google_params.dart';
import 'package:must_invest/features/all/auth/data/models/plan.dart';
import 'package:must_invest/features/all/auth/data/models/register_params.dart';
import 'package:must_invest/features/all/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/all/auth/data/models/user.dart';

abstract class AuthRemoteDataSource {
  // Future<ApiResponse> login();
  Future<ApiResponse<AuthModel>> autoLogin(String token);
  Future<ApiResponse<AuthModel>> login(LoginParams params);
  Future<ApiResponse<AuthModel>> loginWithGoogle(
    LoginWithGoogleParams loginWithGoogleParams,
  );
  Future<ApiResponse<AuthModel>> loginWithApple(
    LoginWithAppleParams loginWithAppleParams,
  );
  Future<ApiResponse<AuthModel>> register(RegisterParams params);
  Future<ApiResponse<void>> forgetPassword(String email);
  Future<ApiResponse<void>> resetPassword(ResetPasswordParams params);
  Future<ApiResponse<List<SubscriptionPlan>>> getPLans();
  Future<ApiResponse<SubscriptionPlan>> subscribePlan(int planId, String token);
  Future<ApiResponse<List<Brand>>> getBrands(int planId);
  Future<ApiResponse<AppUser>> updateLocation(
    String token,
    double latitude,
    double longitude,
    String address,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  // final FcmService fcmService;
  AuthRemoteDataSourceImpl(this.dioClient);

  /// The function `autoLogin` sends a POST request to the `autoLogin` endpoint with login parameters
  /// and returns an ApiResponse containing an AppUser object.
  ///
  /// Args:
  ///   params (LoginParams): The `autoLogin` method takes a `LoginParams` object as a parameter. This
  /// object likely contains the necessary information for the auto-login process, such as username and
  /// password. The `toJson()` method is likely used to convert the `LoginParams` object into a JSON
  /// format that can be sent
  ///
  /// Returns:
  ///   A `Future` of type `ApiResponse<AppUser>` is being returned.
  @override
  Future<ApiResponse<AuthModel>> autoLogin(String token) async {
    return dioClient.request<AuthModel>(
      method: RequestMethod.get,
      EndPoints.autoLogin,
      options: token.toAuthorizationOptions(),
      fromJson: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// The function `login` sends a POST request to the login endpoint with the provided parameters and
  /// returns an ApiResponse containing an AuthModel.
  ///
  /// Args:
  ///   params (LoginParams): The `params` parameter is an instance of the `LoginParams` class, which
  /// contains the username and password of the user trying to log in.
  ///
  /// Returns:
  ///   The `login` method is returning a `Future` that resolves to an `ApiResponse` containing an
  /// `AuthModel` object.
  @override
  Future<ApiResponse<AuthModel>> login(LoginParams params) async {
    // final deviceToken = await fcmService.getDeviceToken();

    // Add artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 2));

    return ApiResponse.fromJson({
      'status': true,
      'message': 'Login successful',
      'token': 'fake_token_123',
      'data': {
        'token': 'fake_token_123',
        'user': {
          'id': 1,
          'name': 'محمود الدنجاوي',
          'email': 'eldengaawy@gmail.com',
          'link_id': '#565678',
          'type':
              (params.email) == 'parkingMan@gmail.com' ? 'parkingMan' : 'user',
          'badges': (params.email == 'parent@gmail.com') ? [] : ['gold'],

          'phone': '01012345678',
          'photo':
              'https://turntable.kagiso.io/images/single_parent_wikimedia.width-800.jpg',
        },
      },
    }, (json) => AuthModel.fromJson(json as Map<String, dynamic>));
    // return dioClient.request<AuthModel>(
    //   method: RequestMethod.post,
    //   EndPoints.login,
    //   // data: params.toJson(deviceToken ?? ''),
    //   fromJson: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    //   onSuccess: () {
    //     // fcmService.subscribeToTopic(Constants.allTopic);
    //   },
    // );
  }

  /// The function `loginWithGoogle` sends a POST request to the login endpoint with Google authentication
  /// parameters and returns an ApiResponse containing an AuthModel.
  ///
  /// Args:
  ///   loginWithGoogleParams (LoginWithGoogleParams): Contains the Google authentication credentials
  /// and other required parameters for logging in with Google.
  ///
  /// Returns:
  ///   A Future that resolves to an ApiResponse containing an AuthModel object with the authenticated
  /// user's data and tokens.
  @override
  Future<ApiResponse<AuthModel>> loginWithGoogle(
    LoginWithGoogleParams loginWithGoogleParams,
  ) async {
    // final deviceToken = await fcmService.getDeviceToken();
    return dioClient.request<AuthModel>(
      method: RequestMethod.post,
      EndPoints.loginWithGoogle,
      // data: loginWithGoogleParams.toJson(deviceToken ?? ''),
      fromJson: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
      onSuccess: () {
        // fcmService.subscribeToTopic(Constants.allTopic);
      },
    );
  }

  /// The function `loginWithApple` sends a POST request to the login endpoint with Apple authentication
  /// parameters and returns an ApiResponse containing an AuthModel.
  ///
  /// Args:
  ///   loginWithAppleParams (LoginWithAppleParams): Contains the Apple authentication credentials
  /// and other required parameters for logging in with Apple.
  ///
  /// Returns:
  ///   A Future that resolves to an ApiResponse containing an AuthModel object with the authenticated
  /// user's data and tokens.
  @override
  Future<ApiResponse<AuthModel>> loginWithApple(
    LoginWithAppleParams loginWithAppleParams,
  ) async {
    // final deviceToken = await fcmService.getDeviceToken();
    return dioClient.request<AuthModel>(
      method: RequestMethod.post,
      EndPoints.loginWithApple,
      // data: loginWithAppleParams.toJson(deviceToken ?? ''),
      fromJson: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
      onSuccess: () {
        // fcmService.subscribeToTopic(Constants.allTopic);
      },
    );
  }

  /// The function `register` sends a POST request to the register endpoint with the provided parameters
  /// and returns an ApiResponse containing an AuthModel.
  ///
  /// Args:
  ///   params (RegisterParams): The `register` method you provided seems to be a part of a class that
  /// implements an interface or extends a base class with a method signature like
  /// `Future<ApiResponse<AuthModel>> register(RegisterParams params)`.
  ///
  /// Returns:
  ///   The `register` method is returning a `Future` that resolves to an `ApiResponse` containing an
  /// `AuthModel` object.
  @override
  Future<ApiResponse<AuthModel>> register(RegisterParams params) async {
    // return dioClient.request<AuthModel>(
    //   method: RequestMethod.post,
    //   EndPoints.register,
    //   data: params.toJson(),
    //   fromJson: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    //   onSuccess: () {
    //     // fcmService.subscribeToTopic(Constants.allTopic);
    //   },
    // );

    return ApiResponse.fromJson({
      'status': true,
      'message': 'Login successful',
      'token': 'fake_token_123',
      'data': {
        'token': 'fake_token_123',
        'user': {
          'id': 1,
          'name': 'محمود الدنجاوي',
          'email': 'eldengaawy@gmail.com',
          'link_id': '#565678',
          'type':
              (params.email) == 'parent@gmail.com' ? 'parent' : 'parkingMan',
          'badges': (params.email == 'parent@gmail.com') ? [] : ['gold'],
          'phone': '01012345678',
          'photo':
              'https://turntable.kagiso.io/images/single_parent_wikimedia.width-800.jpg',
        },
      },
    }, (json) => AuthModel.fromJson(json as Map<String, dynamic>));
  }

  /// The `forgetPassword` function sends a POST request to the `register` endpoint with the provided
  /// email for password reset.
  ///
  /// Args:
  ///   email (String): The `forgetPassword` method is used to send a request to the server to reset a
  /// user's password. The `email` parameter is the email address of the user for whom the password reset
  /// request is being made.
  ///
  /// Returns:
  ///   The `forgetPassword` method is returning a `Future` that resolves to an `ApiResponse<void>`.
  @override
  Future<ApiResponse<void>> forgetPassword(String email) async {
    return dioClient.request<void>(
      method: RequestMethod.post,
      EndPoints.forgetPassword,
      data: {"email": email},
      fromJson: (json) => (),
    );
  }

  /// This function sends a POST request to reset a password using the provided parameters.
  ///
  /// Args:
  ///   params (ResetPasswordParams): The `resetPassword` method takes a `ResetPasswordParams` object as
  /// a parameter. This object likely contains the necessary information to reset a user's password, such
  /// as the user's email address or username.
  ///
  /// Returns:
  ///   The `resetPassword` method is returning a `Future` that resolves to an `ApiResponse<void>`.
  @override
  Future<ApiResponse<void>> resetPassword(ResetPasswordParams params) async {
    return dioClient.request<void>(
      method: RequestMethod.post,
      EndPoints.resetPassword,
      data: params.toJson(),
      fromJson: (json) => (),
    );
  }

  /// This function retrieves a list of subscription plans using Dio client in Dart.
  ///
  /// Returns:
  ///   A Future object that will eventually resolve to an ApiResponse containing a list of
  /// SubscriptionPlan objects.
  @override
  Future<ApiResponse<List<SubscriptionPlan>>> getPLans() async {
    return dioClient.request<List<SubscriptionPlan>>(
      method: RequestMethod.get,
      EndPoints.plans,
      fromJson:
          (json) => List<SubscriptionPlan>.from(
            (json as List).map((plan) => SubscriptionPlan.fromJson(plan)),
          ),
    );
  }

  /// This Dart function subscribes a user to a specific subscription plan using a provided token.
  ///
  /// Args:
  ///   planId (int): The `planId` parameter is an integer value representing the ID of the subscription
  /// plan that the user wants to subscribe to.
  ///   token (String): The `token` parameter in the `subscribePlan` method is used for authentication and
  /// authorization purposes. It is typically a string value that represents the user's authentication
  /// token or access token. This token is usually obtained after a user logs in or authenticates with the
  /// system and is then passed along with the
  ///
  /// Returns:
  ///   The `subscribePlan` method is returning a `Future` that resolves to an `ApiResponse` containing a
  /// `SubscriptionPlan` object.
  @override
  Future<ApiResponse<SubscriptionPlan>> subscribePlan(
    int planId,
    String token,
  ) async {
    return dioClient.request<SubscriptionPlan>(
      method: RequestMethod.post,
      EndPoints.subscribePlan(planId),
      options: token.toAuthorizationOptions(),
      data: {"subscription_id": planId},
      fromJson:
          (json) => SubscriptionPlan.fromJson(
            (json as Map<String, dynamic>)['subscription'],
          ),
    );
  }

  /// The function `getBrands` retrieves a list of brands associated with a specific plan ID using Dio
  /// client in Dart.
  ///
  /// Args:
  ///   planId (int): The `getBrands` method is a function that returns a Future object with
  /// ApiResponse<List<Brand>> as the return type. It takes an integer parameter `planId` which is used to
  /// fetch a list of brands associated with a specific plan.
  ///
  /// Returns:
  ///   The `getBrands` method is returning a `Future` that resolves to an `ApiResponse` containing a list
  /// of `Brand` objects.
  @override
  Future<ApiResponse<List<Brand>>> getBrands(int planId) async {
    return dioClient.request<List<Brand>>(
      method: RequestMethod.get,
      EndPoints.planBrands(planId),
      fromJson:
          (json) => List<Brand>.from(
            ((json as Map<String, dynamic>)['data'] as List).map(
              (brand) => Brand.fromJson(brand),
            ),
          ),
    );
  }

  /// Updates the user's location coordinates in the system.
  ///
  /// Args:
  ///   token (String): Authentication token for the user
  ///   latitude (double): The latitude coordinate of the user's location
  ///   longitude (double): The longitude coordinate of the user's location
  ///
  /// Returns:
  ///   A Future that resolves to an ApiResponse containing the updated AppUser object
  ///   with the new location information
  @override
  Future<ApiResponse<AppUser>> updateLocation(
    String token,
    double latitude,
    double longitude,
    String address,
  ) async {
    return dioClient.request<AppUser>(
      method: RequestMethod.post,
      EndPoints.updateLocation,
      options: token.toAuthorizationOptions(),
      data: {"latitude": latitude, "longitude": longitude, "address": address},
      fromJson: (json) => AppUser.fromJson(json as Map<String, dynamic>),
    );
  }
}
