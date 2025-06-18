import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/features/auth/data/models/governorate.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';

part 'governorates_state.dart';

class GovernoratesCubit extends Cubit<GovernoratesState> {
  GovernoratesCubit(this.authRepo) : super(GovernoratesInitial());
  final AuthRepo authRepo;

  static GovernoratesCubit get(context) => BlocProvider.of(context);

  Future<void> getGovernorates(int countryId) async {
    emit(GovernoratesLoading());

    final result = await authRepo.getGovernorates(countryId);

    result.fold(
      (governorates) => emit(GovernoratesLoaded(governorates)),
      (error) => emit(GovernoratesError(error.message)),
    );
  }
}
