import 'package:flutter/material.dart';
import 'package:monami/handlers/navigation_handler.dart';
import 'package:monami/handlers/snack_bar_handler.dart';
import 'package:monami/state/api_response.dart';
import 'package:monami/utils/router/locator.dart';

///Base view model with shared dependencies injected.
///All view models must extends this class.
class BaseViewModel extends ChangeNotifier {
  late NavigationService navigationHandler;
  late SnackbarHandler snackbarHandler;

  BaseViewModel({
    NavigationService? navigationHandler,
    SnackbarHandler? snackbarHandler,
  }) {
    this.navigationHandler = navigationHandler ?? locator();

    this.snackbarHandler = snackbarHandler ?? locator();
  }
  bool _loading = false;
  bool get loading => _loading;

  void toggleLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void log(Object? e) {
    log(e);
  }

  void showSnackBar(String message) {
    snackbarHandler.showSnackbar(message);
  }

  void showErrorSnackBar(String message) {
    snackbarHandler.showErrorSnackbar(message);
  }

  void handleError(Object e) {
    if (e is ApiErrorResponse) {
      showErrorSnackBar(e.message);
    }
    log(e);
  }
}
