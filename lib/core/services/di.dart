import 'package:get_it/get_it.dart';
import 'package:must_invest/core/api/dio_client.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:must_invest/features/auth/data/repositories/auth_repo.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:must_invest/features/explore/data/repositories/explore_repo.dart';
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

  //* Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(sl()),
  );
}
