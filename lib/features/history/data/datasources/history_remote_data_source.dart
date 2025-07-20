import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/history/data/models/history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<ApiResponse<List<HistoryModel>>> getHistory(String token);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final DioClient dioClient;

  HistoryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<List<HistoryModel>>> getHistory(String token) async {
    return dioClient.request<List<HistoryModel>>(
      method: RequestMethod.get,
      EndPoints.history,
      options: token.toAuthorizationOptions(),
      fromJson:
          (json) => List<HistoryModel>.from(
            (json as List).map((history) => HistoryModel.fromJson(history as Map<String, dynamic>)),
          ),
    );
  }
}
