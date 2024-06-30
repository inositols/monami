import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/providers/user_id_provider.dart';
import 'package:monami/src/features/likes/models/like_dislike_request.dart';

import 'package:monami/src/features/likes/providers/has_likes_provider.dart';
import 'package:monami/src/features/likes/providers/like_dislike_post_provider.dart';
import 'package:monami/src/data/state/post/typedefs/post_id.dart';
import 'package:monami/src/presentation/views/components/animation/models/small_error_animation.dart';

class LikeButton extends ConsumerWidget {
  final PostId postId;

  const LikeButton({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLiked = ref.watch(hasLikedPostProvider(postId));

    return hasLiked.when(
      data: (hasLiked) {
        return IconButton(
          icon: FaIcon(
            hasLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            color: hasLiked ? Colors.red : Colors.white,
          ),
          onPressed: () {
            final userId = ref.read(userIdProvider);
            if (userId == null) {
              return;
            }
            final likeRequest = LikeDislikeRequest(
              postId: postId,
              likedBy: userId.asData!.value!,
            );
            ref.read(
              likeDislikePostProvider(
                likeRequest,
              ),
            );
          },
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
}
