import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/home/data/models/charge_points_response.dart';

abstract class HomeRemoteDataSource {
  Future<ApiResponse<ChargePointsResponse>> chargePoints(String equivalentMoney, String token);
  Future<ApiResponse<void>> pointsWithdrawn(int id, String token);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<ChargePointsResponse>> chargePoints(String equivalentMoney, String token) async {
    return dioClient.request<ChargePointsResponse>(
      method: RequestMethod.post,
      EndPoints.chargePoints,
      options: token.toAuthorizationOptions(),
      data: {'equivalent_money': equivalentMoney},

      contentType: ContentType.json,
      fromJson: (json) => ChargePointsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> pointsWithdrawn(int id, String token) async {
    return dioClient.request<void>(
      method: RequestMethod.post,
      EndPoints.parkingPointsWithdrawn(id),
      options: token.toAuthorizationOptions(),
      contentType: ContentType.json,
      fromJson: (json) {},
    );
  }
}
