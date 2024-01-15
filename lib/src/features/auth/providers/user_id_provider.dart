import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/providers/auth_state_provider.dart';
import 'package:monami/state/post/typedefs/user_id.dart';

final userIdProvider = Provider<UserId?>((ref) {
  return ref.watch(authStateProvider).userId;
});
