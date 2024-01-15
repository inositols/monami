import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/providers/user_id_provider.dart';
import 'package:monami/src/features/comments/models/comments.dart';
import 'package:monami/src/features/comments/providers/delete_comment_provider.dart';
import 'package:monami/state/user_info/provider/user_info_provider.dart';
import 'package:monami/views/components/animation/models/small_error_animation.dart';
import 'package:monami/views/components/constants/strings.dart';
import 'package:monami/views/dialogs/alert_dialog_model.dart';
import 'package:monami/views/dialogs/delete_dialog.dart';

class CommentTile extends ConsumerWidget {
  final Comment comment;
  const CommentTile({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(
      userInfoModelProvider(
        comment.fromUserId,
      ),
    );
    return userInfo.when(
      data: (userInfo) {
        final currentUserId = ref.read(userIdProvider);
        return ListTile(
          trailing: currentUserId == comment.fromUserId
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final shouldDeleteComment =
                        await displayDeleteDialog(context);
                    if (shouldDeleteComment) {
                      await ref
                          .read(
                            deleteCommentProvider.notifier,
                          )
                          .deleteComment(
                            commentId: comment.id,
                          );
                    }
                  },
                )
              : null,
          title: Text(
            userInfo.displayName,
          ),
          subtitle: Text(
            comment.comment,
          ),
        );
      },
      error: (error, stackTrace) {
        return const SmallErrorAnimationView();
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<bool> displayDeleteDialog(BuildContext context) =>
      const DeletedDialog(titleOfObjectToDelete: Strings.comment)
          .present(context)
          .then(
            (value) => value ?? false,
          );
}
