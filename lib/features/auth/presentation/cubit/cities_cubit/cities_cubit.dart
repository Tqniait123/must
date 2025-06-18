import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/features/auth/data/models/city.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';

part 'cities_state.dart';

class CitiesCubit extends Cubit<CitiesState> {
  CitiesCubit(this.authRepo) : super(CitiesInitial());
  final AuthRepo authRepo;

  static CitiesCubit get(context) => BlocProvider.of(context);

  Future<void> getCities(int countryId) async {
    emit(CitiesLoading());

    final result = await authRepo.getCities(countryId);

    result.fold(
      (cities) => emit(CitiesLoaded(cities)),
      (error) => emit(CitiesError(error.message)),
    );
  }
}
