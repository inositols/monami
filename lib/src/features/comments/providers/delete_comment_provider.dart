import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/comments/notifiers/delete_notifier.dart';
import 'package:monami/src/features/image_upload/typedef/is_loading.dart';

final deleteCommentProvider =
    StateNotifierProvider<DeleCommentStateNotifier, IsLoading>(
  (ref) => DeleCommentStateNotifier(),
);
