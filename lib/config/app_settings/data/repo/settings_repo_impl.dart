import 'package:dartz/dartz.dart';
import 'package:must_invest/config/app_settings/data/datasources/settings_remote_data_source.dart';
import 'package:must_invest/config/app_settings/data/models/app_settings_model.dart';
import 'package:must_invest/config/app_settings/domain/repo/settings_repo.dart';

class AppSettingsRepoImpl implements AppSettingsRepo {
  final AppSettingsRemoteDataSource _settingsRemoteDataSource;

  AppSettingsRepoImpl(this._settingsRemoteDataSource);

  @override
  Future<Either<AppSettings, String>> getAppSettings() async {
    return _settingsRemoteDataSource.getAppSettings();
  }
}
