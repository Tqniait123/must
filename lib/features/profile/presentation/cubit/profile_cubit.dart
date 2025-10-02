import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/profile/data/models/parking_process_model.dart';
import 'package:must_invest/features/profile/data/models/update_profile_params.dart';
import 'package:must_invest/features/profile/data/repositories/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final PagesRepo _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  static ProfileCubit get(context) => BlocProvider.of(context);

  Future<void> updateProfile(UpdateProfileParams params) async {
    try {
      emit(ProfileLoading());
      final response = await _repository.updateProfile(params);
      response.fold(
        (userWithMessage) => emit(ProfileSuccess(userWithMessage.user, userWithMessage.message)),
        (error) => emit(ProfileError(error.message)),
      );
    } on AppError catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> startParking(ParkingProcessModel params) async {
    try {
      emit(StartParkingLoading());
      final response = await _repository.startParking(params);
      response.fold((_) => emit(StartParkingSuccess()), (error) => emit(StartParkingError(error.message)));
    } on AppError catch (e) {
      emit(StartParkingError(e.message));
    } catch (e) {
      emit(StartParkingError(e.toString()));
    }
  }

  Future<void> uploadCarParkingImage(int parkingId, PlatformFile image) async {
    try {
      emit(UploadCarImageLoading());
      final response = await _repository.uploadCarParkingImage(parkingId, image);
      response.fold(
        (_) => emit(UploadCarImageSuccess()),
        (error) => emit(UploadCarImageError(error.message)),
      );
    } on AppError catch (e) {
      emit(UploadCarImageError(e.message));
    } catch (e) {
      emit(UploadCarImageError(e.toString()));
    }
  }
}
