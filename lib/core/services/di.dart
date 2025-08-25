import 'package:get_it/get_it.dart';
import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:must_invest/features/explore/data/repositories/explore_repo.dart';
import 'package:must_invest/features/history/data/datasources/history_remote_data_source.dart';
import 'package:must_invest/features/history/data/repositories/history_repo.dart';
import 'package:must_invest/features/home/data/datasources/home_remote_data_source.dart';
import 'package:must_invest/features/home/data/repositories/home_repo.dart';
import 'package:must_invest/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:must_invest/features/notifications/data/repositories/notifications_repo.dart';
import 'package:must_invest/features/offers/data/datasources/offers_remote_data_source.dart';
import 'package:must_invest/features/offers/domain/repositories/offers_repo.dart';
import 'package:must_invest/features/profile/data/datasources/cars_remote_data_source.dart';
import 'package:must_invest/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:must_invest/features/profile/data/repositories/cars_repo.dart';
import 'package:must_invest/features/profile/data/repositories/profile_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initLocator(SharedPreferences sharedPreferences) async {
  // Register SharedPreferences first
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register MustInvestPreferences
  sl.registerLazySingleton(() => MustInvestPreferences(sl()));

  // Register DioClient
  sl.registerLazySingleton(() => DioClient(sl()));

  //? Cubits
  sl.registerFactory<UserCubit>(() => UserCubit());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));

  //* Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl(), sl()));
  sl.registerLazySingleton<ExploreRepo>(() => ExploreRepoImpl(sl(), sl()));
  sl.registerLazySingleton<NotificationsRepo>(() => NotificationsRepoImpl(sl(), sl()));
  sl.registerLazySingleton<PagesRepo>(() => PagesRepoImpl(sl(), sl()));
  sl.registerLazySingleton<CarRepo>(() => CarRepoImpl(sl(), sl()));
  sl.registerLazySingleton<HistoryRepo>(() => HistoryRepoImpl(sl(), sl()));
  sl.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(sl(), sl()));
  sl.registerLazySingleton<OffersRepo>(() => OffersRepoImpl(sl(), sl()));

  //* Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ExploreRemoteDataSource>(() => ExploreRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PagesRemoteDataSource>(() => PagesRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CarRemoteDataSource>(() => CarRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HistoryRemoteDataSource>(() => HistoryRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OffersRemoteDataSource>(() => OffersRemoteDataSourceImpl(sl()));
}
