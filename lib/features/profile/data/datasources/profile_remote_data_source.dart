import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';
import 'package:must_invest/features/profile/data/models/terms_and_conditions_model.dart';

abstract class PagesRemoteDataSource {
  Future<ApiResponse<List<FAQModel>>> getFaq(String? lang);
  Future<ApiResponse<TermsAndConditionsModel>> getTermsAndConditions(String? lang);
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
}
