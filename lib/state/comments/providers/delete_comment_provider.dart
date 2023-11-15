import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/comments/notifiers/delete_notifier.dart';
import 'package:monami/state/image_upload/typedef/is_loading.dart';

final deleteCommentProvider =
    StateNotifierProvider<DeleCommentStateNotifier, IsLoading>(
  (ref) => DeleCommentStateNotifier(),
);
