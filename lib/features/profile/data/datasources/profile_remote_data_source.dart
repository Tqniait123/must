import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';

abstract class PagesRemoteDataSource {
  Future<ApiResponse<List<FAQModel>>> getFaq(String? lang);
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
}
