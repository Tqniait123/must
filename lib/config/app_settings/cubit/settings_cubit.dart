import 'dart:developer';

import 'package:must_invest/config/app_settings/data/models/app_settings_model.dart';
import 'package:must_invest/config/app_settings/domain/repo/settings_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepo _settingsRepo;
  AppSettings? appSettings;

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
          appSettings = settings;
          emit(AppSettingsSuccessState(settings));
        },
        (error) => emit(AppSettingsErrorState(message: error)),
      );
    } catch (e) {
      log(e.toString());
      emit(AppSettingsErrorState(message: e.toString()));
    }
  }

  // Helper functions in Cubit

  /// Converts money amount to points
  /// Returns null if app settings are not loaded
  int? convertMoneyToPoints(double moneyAmount) {
    if (appSettings == null) return null;
    return appSettings!.convertMoneyToPoints(moneyAmount);
  }

  /// Converts points to money amount
  /// Returns null if app settings are not loaded
  double? convertPointsToMoney(int points) {
    if (appSettings == null) return null;
    return appSettings!.convertPointsToMoney(points);
  }

  /// Gets the current exchange rate (how many points equal 1 unit of money)
  /// Returns null if app settings are not loaded
  int? getPointsExchangeRate() {
    return appSettings?.pointsEqualMoney;
  }

  /// Gets the less parking period in minutes
  /// Returns null if app settings are not loaded
  int? getLessParkingPeriod() {
    return appSettings?.lessParkingPeriod;
  }

  /// Calculates total cost in points for a given duration and rate
  /// Returns null if app settings are not loaded
  int? calculateTotalPointsCost(double baseCost) {
    if (appSettings == null) return null;
    return appSettings!.convertMoneyToPoints(baseCost);
  }

  /// Calculates discounted points for less parking period
  /// You can customize this logic based on your business rules
  int? calculateDiscountedPoints(int originalPoints) {
    if (appSettings == null) return originalPoints;
    // Example: 10% discount for less parking period
    return (originalPoints * 0.9).round();
  }
}
