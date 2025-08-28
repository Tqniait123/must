import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/features/offers/data/models/buy_offer_params.dart';
import 'package:must_invest/features/offers/domain/repositories/offers_repo.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/offers/data/models/buy_offer_params.dart';
import 'package:must_invest/features/offers/data/models/payment_model.dart';

part 'buy_offer_state.dart';

class BuyOfferCubit extends Cubit<BuyOfferState> {
  final OffersRepo _repo;
  BuyOfferCubit(this._repo) : super(BuyOfferInitial());

  static BuyOfferCubit get(context) => BlocProvider.of<BuyOfferCubit>(context);

  /// The `buyOffer` function handles purchasing an offer by calling the repository method
  /// and emitting appropriate states based on the response.
  ///
  /// Args:
  ///   params (BuyOfferParams): Contains the offer ID to purchase
  Future<void> buyOffer(BuyOfferParams params) async {
    try {
      emit(BuyOfferLoading());
      final response = await _repo.buyOffer(params);
      response.fold(
        (paymentModel) => emit(BuyOfferSuccess(paymentModel)),
        (error) => emit(BuyOfferError(error.message)),
      );
    } on AppError catch (e) {
      emit(BuyOfferError(e.message));
    } catch (e) {
      emit(BuyOfferError(e.toString()));
    }
  }
}
