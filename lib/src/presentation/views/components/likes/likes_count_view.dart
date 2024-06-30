import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/likes/providers/post_likes_count_provider.dart';
import 'package:monami/src/data/state/post/typedefs/post_id.dart';
import 'package:monami/src/presentation/views/components/animation/models/small_error_animation.dart';
import 'package:monami/src/utils/constants/app_string.dart';

class LikesCountView extends ConsumerWidget {
  final PostId postId;
  const LikesCountView({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesCount = ref.watch(postLikesCountProvider(postId));
    return likesCount.when(
      data: (int likesCount) {
        final personOrPeople =
            likesCount == 1 ? Strings.person : Strings.people;
        final likesText = '$likesCount $personOrPeople ${Strings.likedThis}';
        return Text(likesText);
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
}
