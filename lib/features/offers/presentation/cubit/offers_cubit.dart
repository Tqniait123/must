// offers/presentation/cubit/offers_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/offers/data/models/offer_model.dart';
import 'package:must_invest/features/offers/domain/repositories/offers_repo.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepo offersRepo;
  OffersCubit(this.offersRepo) : super(OffersInitial());

  static OffersCubit get(context) => BlocProvider.of<OffersCubit>(context);

  Future<void> getAllOffers({OfferFilterModel? filter, bool isFirstTime = true}) async {
    try {
      if (isFirstTime) {
        emit(OffersLoading());
      }
      final response = await offersRepo.getAllOffers(filter: filter);
      response.fold((offers) => emit(OffersSuccess(offers)), (error) => emit(OffersError(error.message)));
    } on AppError catch (e) {
      emit(OffersError(e.message));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> getOfferById(int offerId) async {
    try {
      emit(SingleOfferLoading());
      final response = await offersRepo.getOfferById(offerId);
      response.fold((offer) => emit(SingleOfferSuccess(offer)), (error) => emit(SingleOfferError(error.message)));
    } on AppError catch (e) {
      emit(SingleOfferError(e.message));
    } catch (e) {
      emit(SingleOfferError(e.toString()));
    }
  }

  void setLoadingState() {
    emit(OffersLoading());
  }

  void setSingleOfferLoadingState() {
    emit(SingleOfferLoading());
  }
}
