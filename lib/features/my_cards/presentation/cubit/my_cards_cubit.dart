import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_cards_state.dart';

class MyCardsCubit extends Cubit<MyCardsState> {
  MyCardsCubit() : super(MyCardsInitial());
}
