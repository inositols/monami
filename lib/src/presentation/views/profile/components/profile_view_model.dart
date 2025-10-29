import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';
import 'package:monami/src/services/storage_service.dart';

final userProfileProvider =
    AsyncNotifierProvider<ProfileViewModel, Map<String, dynamic>?>(() {
  return ProfileViewModel();
});

class ProfileViewModel extends AsyncNotifier<Map<String, dynamic>?>
    with BaseViewModel {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return loadProfile();
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    try {
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        return {
          'id': currentUser.userId,
          'name': currentUser.displayName ?? 'User',
          'email': currentUser.email ?? 'user@email.com',
          'phone': currentUser.phoneNumber ?? '',
          'status': currentUser.status ?? 'active',
          'role': currentUser.role ?? 'user',
          'lastLogin': DateTime.now().toIso8601String(),
        };
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: firebaseUser.uid)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        return {
          'id': userData[FirebaseFieldName.userId],
          'name': userData[FirebaseFieldName.displayName] ?? 'User',
          'email': userData[FirebaseFieldName.email] ??
              firebaseUser.email ??
              'user@email.com',
          'phone': userData[FirebaseFieldName.phoneNumber] ?? '',
          'status': userData[FirebaseFieldName.status] ?? 'active',
          'role': userData[FirebaseFieldName.role] ?? 'user',
          'lastLogin': DateTime.now().toIso8601String(),
        };
      }

      return {
        'id': firebaseUser.uid,
        'name': firebaseUser.displayName ?? 'User',
        'email': firebaseUser.email ?? 'user@email.com',
        'phone': firebaseUser.phoneNumber ?? '',
        'status': 'active',
        'role': 'user',
        'lastLogin': DateTime.now().toIso8601String(),
      };
    } catch (_) {
      return StorageService.getUserProfile();
    }
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => loadProfile());
  }
}
