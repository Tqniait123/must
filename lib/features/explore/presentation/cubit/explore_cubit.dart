import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit() : super(ExploreInitial());
}
