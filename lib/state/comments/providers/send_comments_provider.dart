import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/state/comments/notifiers/send_comment_notifier.dart';
import 'package:monami/state/image_upload/typedef/is_loading.dart';

final sendCommentProvider =
    StateNotifierProvider<SendCommentNotifier, IsLoading>(
  (_) => SendCommentNotifier(),
);
