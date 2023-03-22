import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/auth/backend/authenticator.dart';

final authenticationProvider = Provider<Authenticator>((ref) {
  return Authenticator();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});
