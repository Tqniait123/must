part of 'languages_cubit.dart';

abstract class LanguagesState extends Equatable {
  const LanguagesState();

  @override
  // List<Object> get props => [identityHashCode(this)];
  List<Object> get props => [identityHashCode(this)];
}

class LanguagesInitial extends LanguagesState {}

class LanguagesUpdating extends LanguagesState {}

class LanguagesUpdated extends LanguagesState {
  final String langCode;

  const LanguagesUpdated(this.langCode);

  @override
  List<Object> get props => [langCode];
}
