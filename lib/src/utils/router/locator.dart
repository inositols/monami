import 'package:get_it/get_it.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/local/local_cache_impl.dart';
import 'package:monami/src/data/local/secure_storage.dart';
import 'package:monami/src/data/local/secure_storage_impl.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/data/remote/auth_service_impl.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/handlers/snack_bar_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

///Registers dependencies
Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton(sharedPreferences);

  //Local storage
  locator.registerLazySingleton<SecureStorage>(
    () => SecureStorageImpl(),
  );

  locator.registerLazySingleton<LocalCache>(
    () => LocalCacheImpl(
      sharedPreferences: locator(),
      storage: locator(),
    ),
  );
  locator.registerLazySingleton<AuthService>(() => AuthServiceImpl(
        localCache: locator(),
      ));
  //Handlers
  locator
      .registerLazySingleton<NavigationService>(() => NavigationServiceImpl());
  locator.registerLazySingleton<SnackbarHandler>(() => SnackbarHandlerImpl());
}
