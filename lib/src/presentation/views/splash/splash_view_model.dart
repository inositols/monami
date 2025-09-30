import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/utils/router/route_name.dart';

final splashViewModelProvider = ChangeNotifierProvider((ref) {
  return SplashViewModel();
});

class SplashViewModel extends BaseViewModel {
  SplashViewModel() {
    checkLoginStatus();
  }
  Future<void> checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // Skip login and go directly to home to test the new UI
      // navigationHandler.pushReplacementNamed(Routes.onboardingViewRoute);

      //Original login check - commented out for UI testing
      final isLoggedIn = localCache.getLoginStatus();

      if (isLoggedIn) {
        navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
      } else {
        navigationHandler.pushReplacementNamed(Routes.onboardingViewRoute);
      }
    } catch (e) {
      log(e);
      await Future.delayed(const Duration(milliseconds: 800));
      // Skip login on error too - go directly to home for UI testing
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    }
  }
}
