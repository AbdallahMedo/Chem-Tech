import 'package:get_it/get_it.dart';

import '../../features/data/presentation/cubit/data_cubit.dart';
import '../../features/home/data/presentation/cubit/scan_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Cubits
  sl.registerFactory(() => SplashCubit());
  sl.registerFactory(() => ScanCubit());
  sl.registerFactory(() => DataCubit());


  // Repositories
  // sl.registerLazySingleton<YourRepository>(() => YourRepositoryImpl());

  // Use Cases
  // sl.registerLazySingleton<YourUseCase>(() => YourUseCase(repository: sl()));

  // Services
  // sl.registerLazySingleton<YourService>(() => YourService());
}
