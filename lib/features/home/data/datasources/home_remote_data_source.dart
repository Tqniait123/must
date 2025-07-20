import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';

abstract class HomeRemoteDataSource {
  Future<ApiResponse<void>> chargePoints(String equivalentMoney, String token);
  Future<ApiResponse<void>> pointsWithdrawn(int id, String token);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<void>> chargePoints(String equivalentMoney, String token) async {
    return dioClient.request<void>(
      method: RequestMethod.post,
      EndPoints.chargePoints,
      options: token.toAuthorizationOptions(),
      data: {'equivalentMoney': equivalentMoney},

      contentType: ContentType.json,
      fromJson: (json) {},
    );
  }

  @override
  Future<ApiResponse<void>> pointsWithdrawn(int id, String token)async  {
    return dioClient.request<void>(
      method: RequestMethod.post,
      EndPoints.parkingPointsWithdrawn(id),
      options: token.toAuthorizationOptions(),
      contentType: ContentType.json,
      fromJson: (json) {},
    );
  }
}
