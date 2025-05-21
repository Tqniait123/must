import 'package:get_it/get_it.dart';
import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/all/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/all/auth/data/repositories/auth_repo.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

// function that ensure the locator is initialized before the app starts
Future<void> ensureLocatorInitialized() async {
  if (!GetIt.I.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPreferences);
  }
  // if (!GetIt.I.isRegistered<FcmService>()) {
  //   sl.registerSingleton<FcmService>(FcmService(preferences: sl()));
  // }
}

Future<void> initLocator() async {
  //? Cubits
  sl.registerFactory<UserCubit>(() => UserCubit());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));
  // Register OffersCubit

  //* Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl(), sl()));

  //* Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  //! Core

  //! External
  final SharedPreferences sharedPref = await SharedPreferences.getInstance();

  // sl.registerLazySingleton<FcmService>(() => FcmService(preferences: sl()));
  sl.registerLazySingleton(() => MustIvestPreferences(sharedPref));
  sl.registerLazySingleton(() => DioClient(sl()));
}
