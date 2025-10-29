import 'dart:math';

import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/handlers/navigation_handler.dart';
import 'package:monami/src/handlers/snack_bar_handler.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/data/state/api_response.dart';

mixin BaseViewModel {
  late final NavigationService navigationHandler = locator<NavigationService>();
  late final SnackbarHandler snackbarHandler = locator<SnackbarHandler>();
  late final LocalCache localCache = locator<LocalCache>();
  late final AuthService authService = locator<AuthService>();

  void showSnackBar(String message) {
    snackbarHandler.showSnackbar(message);
  }

  void showErrorSnackBar(String message) {
    snackbarHandler.showErrorSnackbar(message);
  }

  void handleError(Object error) {
    if (error is ApiErrorResponse) {
      showErrorSnackBar(error.message);
    }
    log(e);
  }
}
