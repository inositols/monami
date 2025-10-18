import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/data/remote/user_service.dart';
import 'package:monami/src/data/state/user_info/models/user_info_model.dart';

/// Provider for UserService - simplified version
final userServiceProvider = Provider<UserService>((ref) {
  // For now, we'll create a simple instance
  // In a real app, you'd inject dependencies properly
  return UserService(
    authService: ref.read(authServiceProvider),
    localCache: ref.read(localCacheProvider),
  );
});

/// Provider for current user data
final currentUserProvider = FutureProvider<UserInfoModel?>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getCurrentUser();
});

/// Provider for current user profile (Map format for UI)
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getCurrentUserProfile();
});

// Placeholder providers - you'll need to implement these based on your existing setup
final authServiceProvider = Provider((ref) => throw UnimplementedError('Implement auth service provider'));
final localCacheProvider = Provider((ref) => throw UnimplementedError('Implement local cache provider'));
