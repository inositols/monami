import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:monami/state/post/models/post.dart';
import 'package:monami/state/user_info/provider/user_info_provider.dart';
import 'package:monami/views/components/animation/models/small_error_animation.dart';
import 'package:monami/views/components/rich_text_view.dart';

class PostDisplayNameAndMessageView extends ConsumerWidget {
  final Post post;
  const PostDisplayNameAndMessageView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(
      userInfoModelProvider(post.userId),
    );

    return userInfoModel.when(
      data: (userInfoModel) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichTwoPartsText(
            leftPart: "@${userInfoModel.displayName}",
            rightPart: post.message,
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
}
