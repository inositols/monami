import 'package:get_it/get_it.dart';
import 'package:monami/handlers/navigation_handler.dart';
import 'package:monami/handlers/snack_bar_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton(sharedPreferences);

  locator
      .registerLazySingleton<NavigationService>(() => NavigationServiceImpl());
  locator.registerLazySingleton<SnackbarHandler>(() => SnackbarHandlerImpl());
}
