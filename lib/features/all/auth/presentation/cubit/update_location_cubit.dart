import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/all/auth/data/models/user.dart';
import 'package:must_invest/features/all/auth/data/repositories/auth_repo.dart';

part 'update_location_state.dart';

class UpdateLocationCubit extends Cubit<UpdateLocationState> {
  final AuthRepo authRepo;
  UpdateLocationCubit(this.authRepo) : super(UpdateLocationInitial());

  static UpdateLocationCubit get(context) => BlocProvider.of(context);

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String address = '',
  }) async {
    try {
      emit(UpdateLocationLoading());
      final response = await authRepo.updateLocation(
        latitude,
        longitude,
        address,
      );
      response.fold(
        (updatedUser) => emit(UpdateLocationSuccess(updatedUser)),
        (error) => emit(UpdateLocationError(error.message)),
      );
    } on AppError catch (e) {
      emit(UpdateLocationError(e.message));
    } catch (e) {
      emit(UpdateLocationError(e.toString()));
    }
  }
}
