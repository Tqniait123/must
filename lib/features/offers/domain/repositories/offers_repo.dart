// offers/data/repositories/offers_repo.dart
import 'package:dartz/dartz.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/offers/data/datasources/offers_remote_data_source.dart';
import 'package:must_invest/features/offers/data/models/buy_offer_params.dart';
import 'package:must_invest/features/offers/data/models/offer_model.dart';
import 'package:must_invest/features/offers/data/models/payment_model.dart';

abstract class OffersRepo {
  Future<Either<List<Offer>, AppError>> getAllOffers({OfferFilterModel? filter});
  Future<Either<Offer, AppError>> getOfferById(int offerId);
  Future<Either<PaymentModel, AppError>> buyOffer(BuyOfferParams params);
}

class OffersRepoImpl implements OffersRepo {
  final OffersRemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  OffersRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<List<Offer>, AppError>> getAllOffers({OfferFilterModel? filter}) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getAllOffers(token ?? '', filter: filter);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<Offer, AppError>> getOfferById(int offerId) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.getOfferById(token ?? '', offerId);

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }

  @override
  Future<Either<PaymentModel, AppError>> buyOffer(BuyOfferParams params) async {
    try {
      final token = _localDataSource.getToken();
      final response = await _remoteDataSource.buyOffer(params, token ?? '');

      if (response.isSuccess) {
        return Left(response.data!);
      } else {
        return Right(AppError(message: response.errorMessage, apiResponse: response, type: ErrorType.api));
      }
    } catch (e) {
      return Right(AppError(message: e.toString(), type: ErrorType.unknown));
    }
  }
}
