import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/utils/router/route_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      
      // Demo credentials for testing
      if (email == 'demo@monami.com' && password == 'demo123') {
        await _saveTestUserProfile();
        toggleLoading(false);
        navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
        return;
      }
      
      await authService.login(email: email, password: password);
      toggleLoading(false);
      navigationHandler.pushReplacementNamed(Routes.homeViewRoute);
    } catch (e) {
      toggleLoading(false);
      handleError(e);
    }
  }

  Future<void> _saveTestUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String userProfileKey = 'user_profile';
      
      final userProfile = {
        'id': 'demo_user_123',
        'name': 'Demo User',
        'email': 'demo@monami.com',
        'phone': '+234 801 234 5678',
        'status': 'active',
        'role': 'user',
        'lastLogin': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(userProfileKey, jsonEncode(userProfile));
      await prefs.setBool('loginStatus', true);
    } catch (e) {
      print('Error saving test user profile: $e');
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
