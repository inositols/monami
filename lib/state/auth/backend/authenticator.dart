import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monami/state/auth/constants/constants.dart';
import 'package:monami/state/auth/models/auth_result.dart';
import 'package:monami/state/user_info/typedefs/user_id.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

class Authenticator {
  Authenticator();

  final FirebaseAuth user = FirebaseAuth.instance;
  UserId? get userId => user.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;

  String get displayName => user.currentUser?.displayName ?? '';
  String? get email => user.currentUser?.email;

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
      e.log();
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
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        AuthConstants.emailScope,
      ],
    );
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }
    final googleAuth = await signInAccount.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    try {
      await user.signInWithCredential(
        oauthCredential,
      );
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
