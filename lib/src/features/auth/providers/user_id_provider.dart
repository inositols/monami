import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/data/state/user_info/typedefs/user_id.dart';
import 'package:monami/src/features/auth/providers/auth_state_provider.dart';

final userIdProvider = FutureProvider<UserId?>((ref) async {
  final user = ref.watch(authenticationProvider).localCache;
  return user.getUserId();
});
