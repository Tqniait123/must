part of 'user_cubit.dart';

sealed class UserState extends Equatable {}

class UserUnauthenticated extends UserState {
  @override
  List<Object?> get props => [];
}

class UserAuthenticated extends UserState {
  final AppUser user;

  UserAuthenticated(this.user);

  @override
  List<Object?> get props => [identityHashCode(this), user];
}

class UserUpdateLoading extends UserAuthenticated {
  UserUpdateLoading(super.user);
}

class UserUpdateFail extends UserAuthenticated {
  final String message;
  UserUpdateFail(super.user, this.message);
}

class UserUpdateSuccess extends UserAuthenticated {
  UserUpdateSuccess(super.user);
}

class UserUpdatePhotoLoading extends UserAuthenticated {
  UserUpdatePhotoLoading(super.user);
}

class UserUpdatePhotoFail extends UserAuthenticated {
  final String message;
  UserUpdatePhotoFail(super.user, this.message);
}

class UserUpdatePhotoSuccess extends UserAuthenticated {
  UserUpdatePhotoSuccess(super.user);
}
