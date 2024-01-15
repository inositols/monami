import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/image_upload/typedef/is_loading.dart';
import 'package:monami/state/post/notifiers/delete_post_notifier.dart';

final deletePostProvider =
    StateNotifierProvider<DeletePostStateNotifier, IsLoading>(
  (ref) => DeletePostStateNotifier(),
);
