import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/backend/authenticator.dart';
import 'package:monami/src/features/auth/models/auth_state.dart';
import 'package:monami/src/features/auth/notifiers/auth_state_notifier.dart';

final authenticationProvider = Provider<Authenticator>((ref) {
  return Authenticator();
});

final authenticationChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authenticationProvider);
  return auth.authStateChange;
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((_) {
  return AuthStateNotifier();
});
