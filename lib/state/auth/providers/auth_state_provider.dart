import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/auth/backend/authenticator.dart';
import 'package:monami/state/auth/models/auth_state.dart';
import 'package:monami/state/auth/notifiers/auth_state_notifier.dart';

final authenticationProvider = Provider<Authenticator>((ref) {
  return Authenticator();
});

final authStateProvider1 = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((_) {
  return AuthStateNotifier();
});
