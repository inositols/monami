import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/user_info/typedefs/backend/users_info_storage.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';
import 'package:monami/utils/router/route_name.dart';

import '../backend/authenticator.dart';
import '../models/auth_result.dart';
import '../models/auth_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  AuthStateNotifier() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logout();
    state = const AuthState.unknown();
    _authenticator.navigationHandler.pushReplacementNamed(loginRoute);
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithEmail(
      email,
      password,
    );
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      //move to them to the homescreen
      _authenticator.navigationHandler.pushNamed(home);
      _authenticator.showSnackBar("Login successfully");
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> signUp(String email, String password, String username) async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.signUp(
      email,
      password,
    );
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: username,
        email: email,
      );
      await _authenticator.navigationHandler.pushNamed(home);
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> saveUserInfo({
    required UserId userId,
  }) =>
      _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
      );
}
