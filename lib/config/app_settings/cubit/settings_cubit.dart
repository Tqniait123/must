import 'dart:developer';

import 'package:must_invest/config/app_settings/data/models/app_settings_model.dart';
import 'package:must_invest/config/app_settings/domain/repo/settings_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepo _settingsRepo; // Renamed for clarity
  AppSettings? appSettings; // Added to hold the app settings object

  AppSettingsCubit(
    this._settingsRepo,
  ) : super(AppSettingsInitial());

  static AppSettingsCubit get(context) => BlocProvider.of(context);

  Future<void> getAppSettings() async {
    emit(AppSettingsLoadingState());
    try {
      final Either<AppSettings, String> result =
          await _settingsRepo.getAppSettings();
      result.fold(
        (settings) {
          appSettings = settings; // Store the settings in the object
          emit(AppSettingsSuccessState(settings));
        },
        (error) => emit(AppSettingsErrorState(message: error)),
      );
    } catch (e) {
      log(e.toString());
      emit(AppSettingsErrorState(message: e.toString()));
    }
  }
}
