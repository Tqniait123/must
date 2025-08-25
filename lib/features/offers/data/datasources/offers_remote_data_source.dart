
// offers/data/datasources/offers_remote_data_source.dart
import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/api/end_points.dart';
import 'package:must_invest/core/api/response/response.dart';
import 'package:must_invest/core/extensions/token_to_authorization_options.dart';
import 'package:must_invest/features/offers/data/models/offer_model.dart';

abstract class OffersRemoteDataSource {
  Future<ApiResponse<List<Offer>>> getAllOffers(String token, {OfferFilterModel? filter});
  Future<ApiResponse<Offer>> getOfferById(String token, int offerId);
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final DioClient dioClient;

  OffersRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ApiResponse<List<Offer>>> getAllOffers(String token, {OfferFilterModel? filter}) async {
    return dioClient.request<List<Offer>>(
      method: RequestMethod.get,
      EndPoints.offers, // Add this to your EndPoints class
      options: token.toAuthorizationOptions(),
      queryParams: filter?.toJson(),
      contentType: ContentType.formData,
      fromJson: (json) =>
          List<Offer>.from((json as List).map((offer) => Offer.fromJson(offer as Map<String, dynamic>))),
    );
  }

  @override
  Future<ApiResponse<Offer>> getOfferById(String token, int offerId) async {
    return dioClient.request<Offer>(
      method: RequestMethod.get,
      '${EndPoints.offers}/$offerId', // Add this endpoint pattern
      options: token.toAuthorizationOptions(),
      contentType: ContentType.formData,
      fromJson: (json) => Offer.fromJson(json as Map<String, dynamic>),
    );
  }
}
