import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/utils/router/route_name.dart';

final loginViewModelProvider = ChangeNotifierProvider((_) {
  return LoginViewModel();
});

class LoginViewModel extends BaseViewModel {
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      toggleLoading(true);
      await authService.login(email: email, password: password);
      toggleLoading(false);
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    } catch (e) {
      toggleLoading(false);
      handleError(e);
    }
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      toggleLoading(true);
      await authService.signUp(
          email: email, password: password, username: username);
      toggleLoading(false);
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    } catch (e) {
      toggleLoading(false);
      handleError(e);
    }
  }
}
