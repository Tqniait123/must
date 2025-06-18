import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserUnauthenticated());
  static UserCubit get(context) => BlocProvider.of(context);
  User? currentUser;

  void setCurrentUser(User user) {
    currentUser = user;
    emit(UserAuthenticated(user));
  }

  void removeCurrentUser() {
    currentUser = null;
    emit(UserUnauthenticated());
  }

  bool isLoggedIn() {
    return currentUser != null;
  }
}
