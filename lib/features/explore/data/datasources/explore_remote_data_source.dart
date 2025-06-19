import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';

abstract class ExploreRemoteDataSource {
  Future<ApiResponse<List<Parking>>> getAllParkings(String token);
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final DioClient dioClient;

  ExploreRemoteDataSourceImpl(this.dioClient);
  @override
  Future<ApiResponse<List<Parking>>> getAllParkings(String token) async {
    return dioClient.request<List<Parking>>(
      method: RequestMethod.get,
      EndPoints.parking,
      options: token.toAuthorizationOptions(),
      fromJson:
          (json) => List<Parking>.from(
            (json as List).map(
              (parking) => Parking.fromJson(parking as Map<String, dynamic>),
            ),
          ),
    );
  }
}
