import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/utils/logger.dart';

/// Helper class to debug authentication issues
class AuthDebugHelper {
  static final _logger = Logger(AuthDebugHelper);
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Check if a user exists in Firestore
  static Future<bool> userExistsInFirestore(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: uid)
          .get();
      
      _logger.log('User exists in Firestore: ${querySnapshot.docs.isNotEmpty}');
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.log('Error checking user existence: $e');
      return false;
    }
  }

  /// Get all users from Firestore (for debugging)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.users)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'data': doc.data(),
      }).toList();
    } catch (e) {
      _logger.log('Error getting all users: $e');
      return [];
    }
  }

  /// Check current Firebase Auth user
  static Future<Map<String, dynamic>?> getCurrentAuthUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'emailVerified': user.emailVerified,
      };
    } catch (e) {
      _logger.log('Error getting current auth user: $e');
      return null;
    }
  }

  /// Debug login process
  static Future<void> debugLogin(String email, String password) async {
    try {
      _logger.log('Starting login debug for: $email');
      
      // Check Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        _logger.log('Firebase Auth login failed - no user returned');
        return;
      }
      
      _logger.log('Firebase Auth login successful - UID: ${user.uid}');
      
      // Check Firestore
      final exists = await userExistsInFirestore(user.uid);
      _logger.log('User exists in Firestore: $exists');
      
      if (!exists) {
        _logger.log('User not found in Firestore - this is the issue!');
        final allUsers = await getAllUsers();
        _logger.log('All users in Firestore: $allUsers');
      }
      
    } catch (e) {
      _logger.log('Login debug error: $e');
    }
  }
}




