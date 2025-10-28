import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/login/login_state.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/utils/router/route_name.dart';

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(() {
  return LoginViewModel();
});

class LoginViewModel extends Notifier<LoginState> with BaseViewModel {
  @override
  LoginState build() {
    return const LoginState();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await authService.login(email: email, password: password);
      state = state.copyWith(isLoading: false);
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      handleError(e);
    }
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await authService.signUp(
        email: email,
        password: password,
        username: username,
      );
      state = state.copyWith(isLoading: false);
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      handleError(e);
    }
  }
}
