import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/models/about_us_model.dart';
import 'package:must_invest/features/profile/data/models/contact_us_model.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';
import 'package:must_invest/features/profile/data/models/privacy_policy_model.dart';
import 'package:must_invest/features/profile/data/models/terms_and_conditions_model.dart';
import 'package:must_invest/features/profile/data/models/update_profile_params.dart';

abstract class PagesRemoteDataSource {
  Future<ApiResponse<List<FAQModel>>> getFaq(String? lang);
  Future<ApiResponse<User>> updateProfile(String token, UpdateProfileParams params);
  Future<ApiResponse<TermsAndConditionsModel>> getTermsAndConditions(String? lang);
  Future<ApiResponse<PrivacyPolicyModel>> getPrivacyPolicy(String? lang);
  Future<ApiResponse<ContactUsModel>> getContactUs(String? lang);
  Future<ApiResponse<AboutUsModel>> getAboutUs(String? lang);
}

class PagesRemoteDataSourceImpl implements PagesRemoteDataSource {
  final DioClient dioClient;

  PagesRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<List<FAQModel>>> getFaq(lang) async {
    return dioClient.request<List<FAQModel>>(
      method: RequestMethod.get,
      EndPoints.faqs,
      fromJson:
          (json) => List<FAQModel>.from((json as List).map((faq) => FAQModel.fromJson(faq as Map<String, dynamic>))),
    );
  }

  @override
  Future<ApiResponse<TermsAndConditionsModel>> getTermsAndConditions(String? lang) async {
    return dioClient.request<TermsAndConditionsModel>(
      method: RequestMethod.get,
      EndPoints.terms(lang ?? 'en'),
      fromJson: (json) => TermsAndConditionsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PrivacyPolicyModel>> getPrivacyPolicy(String? lang) async {
    return dioClient.request<PrivacyPolicyModel>(
      method: RequestMethod.get,
      EndPoints.privacyPolicy(lang ?? 'en'),
      fromJson: (json) => PrivacyPolicyModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ContactUsModel>> getContactUs(String? lang) async {
    return dioClient.request<ContactUsModel>(
      method: RequestMethod.get,
      EndPoints.contactUs,
      fromJson: (json) => ContactUsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AboutUsModel>> getAboutUs(String? lang) async {
    return dioClient.request<AboutUsModel>(
      method: RequestMethod.get,
      EndPoints.aboutUs(lang ?? 'en'),
      fromJson: (json) => AboutUsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<User>> updateProfile(String token, UpdateProfileParams params) async {
    final formData = await params.toFormData();
    return dioClient.request<User>(
      method: RequestMethod.post,
      EndPoints.updateProfile,
      options: token.toAuthorizationOptions(),
      data: formData,
      contentType: ContentType.formData,
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }
}
