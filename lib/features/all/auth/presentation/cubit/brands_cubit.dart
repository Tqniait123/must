import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/errors/app_error.dart';
import 'package:must_invest/features/all/auth/data/models/brands.dart';
import 'package:must_invest/features/all/auth/data/repositories/auth_repo.dart';

part 'brands_state.dart';

class BrandsCubit extends Cubit<BrandsState> {
  final AuthRepo _repo;
  BrandsCubit(this._repo) : super(BrandsInitial());

  static BrandsCubit get(context) => BlocProvider.of<BrandsCubit>(context);

  Future<void> getBrands(int planId) async {
    try {
      emit(BrandsLoading());
      final response = await _repo.getBrands(planId);
      response.fold(
        (brands) => emit(BrandsSuccess(brands)),
        (error) => emit(BrandsError(error.message)),
      );
    } on AppError catch (e) {
      emit(BrandsError(e.message));
    } catch (e) {
      emit(BrandsError(e.toString()));
    }
  }
}
