import 'package:flutter/material.dart';
import 'package:monami/src/handlers/navigation_handler.dart';
import 'package:monami/src/handlers/snack_bar_handler.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/state/api_response.dart';

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
