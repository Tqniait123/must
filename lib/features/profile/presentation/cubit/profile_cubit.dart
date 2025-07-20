import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
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
      response.fold((user) => emit(ProfileSuccess(user)), (error) => emit(ProfileError(error.message)));
    } on AppError catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
