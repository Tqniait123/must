import 'package:flutter/material.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';

extension UserCubitX on BuildContext {
  UserCubit get userCubit => UserCubit.get(this);

  bool get isLoggedIn => userCubit.isLoggedIn();
  void setCurrentUser(User user) => userCubit.setCurrentUser(user);
  void updateUserPoints(int points) => userCubit.updateUserPoints(points);
  User get user => UserCubit.get(this).currentUser!;
}
