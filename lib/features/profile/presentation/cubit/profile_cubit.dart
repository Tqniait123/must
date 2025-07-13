import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/profile/data/repositories/profile_repo.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_state.dart';

class PagesCubit extends Cubit<PagesState> {
  final PagesRepo _repository;

  PagesCubit(this._repository) : super(PagesInitial());

  static PagesCubit get(context) => BlocProvider.of(context);

  Future<void> getFaq({String? lang}) async {
    try {
      emit(PagesLoading());
      final response = await _repository.getFaq(lang);
      response.fold((faqs) => emit(PagesSuccess(faqs)), (error) => emit(PagesError(error.message)));
    } on AppError catch (e) {
      emit(PagesError(e.message));
    } catch (e) {
      emit(PagesError(e.toString()));
    }
  }

  Future<void> getTermsAndConditions({String? lang}) async {
    try {
      emit(PagesLoading());
      final response = await _repository.getTermsAndConditions(lang);
      response.fold((faqs) => emit(PagesSuccess(faqs)), (error) => emit(PagesError(error.message)));
    } on AppError catch (e) {
      emit(PagesError(e.message));
    } catch (e) {
      emit(PagesError(e.toString()));
    }
  }

  Future<void> getPrivacyPolicy({String? lang}) async {
    try {
      emit(PagesLoading());
      final response = await _repository.getPrivacyPolicy(lang);
      response.fold((privacyPolicy) => emit(PagesSuccess(privacyPolicy)), (error) => emit(PagesError(error.message)));
    } on AppError catch (e) {
      emit(PagesError(e.message));
    } catch (e) {
      emit(PagesError(e.toString()));
    }
  }

  Future<void> getContactUs({String? lang}) async {
    try {
      emit(PagesLoading());
      final response = await _repository.getContactUs(lang);
      response.fold((contactUs) => emit(PagesSuccess(contactUs)), (error) => emit(PagesError(error.message)));
    } on AppError catch (e) {
      emit(PagesError(e.message));
    } catch (e) {
      emit(PagesError(e.toString()));
    }
  }
   Future<void> getAboutUs({String? lang}) async {
    try {
      emit(PagesLoading());
      final response = await _repository.getAboutUs(lang);
      response.fold((faqs) => emit(PagesSuccess(faqs)), (error) => emit(PagesError(error.message)));
    } on AppError catch (e) {
      emit(PagesError(e.message));
    } catch (e) {
      emit(PagesError(e.toString()));
    }
  }
}
