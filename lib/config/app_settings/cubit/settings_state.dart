part of 'settings_cubit.dart';

abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object> get props => [];
}

class AppSettingsInitial extends AppSettingsState {}

class AppSettingsLoadingState extends AppSettingsState {}

class AppSettingsSuccessState extends AppSettingsState {
  final AppSettings settings;

  const AppSettingsSuccessState(this.settings);
}

class AppSettingsErrorState extends AppSettingsState {
  final String message;

  const AppSettingsErrorState({required this.message});
}
