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


}
