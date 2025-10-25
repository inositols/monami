import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/data/state/user_info/models/user_info_model.dart';
import 'package:monami/src/utils/logger.dart';

/// Service to get current user information from Firebase
class UserService {
  final AuthService _authService;
  final LocalCache _localCache;
  final _logger = Logger(UserService);

  UserService({
    required AuthService authService,
    required LocalCache localCache,
  }) : _authService = authService,
       _localCache = localCache;

  /// Get current user information from Firebase
  Future<UserInfoModel?> getCurrentUser() async {
    try {
      // Get current Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        _logger.log('No Firebase user found');
        return null;
      }

      // Get user details from Firestore
      final userInfo = await _authService.getUser(firebaseUser.uid);
      if (userInfo == null) {
        _logger.log('User not found in Firestore for UID: ${firebaseUser.uid}');
        return null;
      }

      _logger.log('Successfully retrieved user: ${userInfo.displayName}');
      return userInfo;
    } catch (e) {
      _logger.log('Error getting current user: $e');
      return null;
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      return firebaseUser?.uid;
    } catch (e) {
      _logger.log('Error getting current user ID: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      return firebaseUser != null;
    } catch (e) {
      _logger.log('Error checking authentication: $e');
      return false;
    }
  }

  /// Get user profile data as Map for UI compatibility
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userInfo = await getCurrentUser();
      if (userInfo == null) return null;

      return {
        'id': userInfo.userId,
        'name': userInfo.displayName,
        'email': userInfo.email,
        'phone': userInfo.phoneNumber,
        'status': userInfo.status,
        'role': userInfo.role,
        'lastLogin': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.log('Error getting user profile: $e');
      return null;
    }
  }
}



