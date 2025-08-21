import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/data/repositories/explore_repo.dart';

part 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final ExploreRepo exploreRepo;
  ExploreCubit(this.exploreRepo) : super(ExploreInitial());

  static ExploreCubit get(context) => BlocProvider.of<ExploreCubit>(context);

  Future<void> getAllParkings({FilterModel? filter}) async {
    try {
      emit(ParkingsLoading());
      final response = await exploreRepo.getAllParkings(filter: filter);
      response.fold((parkings) => emit(ParkingsSuccess(parkings)), (error) => emit(ParkingsError(error.message)));
    } on AppError catch (e) {
      emit(ParkingsError(e.message));
    } catch (e) {
      emit(ParkingsError(e.toString()));
    }
  }

  void setLoadingState() {
    emit(ParkingsLoading());
  }
}
