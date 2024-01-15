import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/comments/notifiers/send_comment_notifier.dart';
import 'package:monami/src/features/image_upload/typedef/is_loading.dart';

final sendCommentProvider =
    StateNotifierProvider<SendCommentNotifier, IsLoading>(
  (_) => SendCommentNotifier(),
);
