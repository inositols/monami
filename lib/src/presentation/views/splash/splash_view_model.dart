import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/utils/router/route_name.dart';

final splashViewModelProvider =
    NotifierProvider<SplashViewModel, bool>(SplashViewModel.new);

class SplashViewModel extends Notifier<bool> with BaseViewModel {
  @override
  bool build() {
    checkLoginStatus();
    return false;
  }

  Future<void> checkLoginStatus() async {
    state = true;
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
      state = false;
      log(e.toString());
    }
  }
}
