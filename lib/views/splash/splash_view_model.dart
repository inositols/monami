import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/utils/router/route_name.dart';
import 'package:monami/views/view_models/base_model.dart';

final splashViewModelProvider = ChangeNotifierProvider((ref) {
  return SplashViewModel();
});

class SplashViewModel extends BaseViewModel {
  SplashViewModel() {
    checkLoginStatus();
  }
  Future<void> checkLoginStatus() async {
    try {
      final isLoggedIn = localCache.getLoginStatus();

      await Future.delayed(const Duration(milliseconds: 1500));

      if (isLoggedIn) {
        navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
      } else {
        navigationHandler.pushReplacementNamed(Routes.onboardingViewRoute);
      }
    } catch (e) {
      log(e);
      await Future.delayed(const Duration(milliseconds: 800));
      navigationHandler.pushReplacementNamed(Routes.loginViewRoute);
    }
  }
}
