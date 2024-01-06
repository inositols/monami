import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/auth/models/auth_result.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';
import 'dart:developer' as devtools show log;

import 'package:monami/views/view_models/base_model.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class Authenticator extends BaseViewModel {
  Authenticator();

  final FirebaseAuth user = FirebaseAuth.instance;
  UserId? get userId => user.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;

  String get displayName => user.currentUser?.displayName ?? '';
  String? get email => user.currentUser?.email;

  Stream<User?> get authStateChange => user.authStateChanges();

  Future<void> logout() async {
    await user.signOut();
    await GoogleSignIn().signOut();
  }

  Future<AuthResult> signUp(String email, String password) async {
    try {
      await user.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success;
    } catch (e) {
      handleError(e);
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      await user.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      e.log();
      handleError(e);
      return AuthResult.failure;
    }
  }
}
