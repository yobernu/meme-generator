import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:memes/core/network_info/network_info.dart';
import 'package:memes/core/utils/input_converter.dart';
import 'package:memes/memes/data/datasources/meme_local_Data_sources.dart';
import 'package:memes/memes/data/datasources/meme_remote_data_sources.dart';
import 'package:memes/memes/data/repository/repository.dart';
import 'package:memes/memes/domain/repository/repository.dart';
import 'package:memes/memes/domain/usecases/cache_meme.dart';
import 'package:memes/memes/domain/usecases/create_meme_usecase.dart';
import 'package:memes/memes/domain/usecases/get_memes_usecases.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  final ls = GetIt.instance;

  // Bloc
  ls.registerFactory(
    () => MemeBloc(
      getMemesUseCase: ls(),
      createMemeUseCase: ls(),
      cacheMemeUseCase: ls(),
    ),
  );

  // Repositories
  ls.registerLazySingleton<MemesRepository>(
    () => MemesRepositoryImpl(
      remoteDataSource: ls(),
      localDataSource: ls(),
      networkInfo: ls(),
    ),
  );

  // DataSources
  ls.registerLazySingleton<MemeRemoteDataSourcesImpl>(
    () => MemeRemoteDataSourcesImpl(client: ls(), networkInfo: ls()),
  );
  ls.registerLazySingleton<MemeLocalDataSourcesImpl>(
    () => MemeLocalDataSourcesImpl(sharedPreferences: ls()),
  );

  // Use cases
  ls.registerLazySingleton(() => GetMemesUseCase(ls()));
  ls.registerLazySingleton(() => CreateMemeUseCase(ls()));
  ls.registerLazySingleton(() => CacheMemeUseCase(ls()));

  // Core
  ls.registerLazySingleton(() => InputConverter());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  ls.registerLazySingleton(() => sharedPreferences);
  ls.registerLazySingleton(() => http.Client());
  ls.registerLazySingleton(() => InternetConnectionChecker.instance);
  ls.registerLazySingleton(() => GetIt.asNewInstance());
  ls.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.instance),
  );
}
