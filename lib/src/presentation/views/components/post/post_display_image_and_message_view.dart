import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/data/provider/auth_service_provider.dart';
import 'package:monami/src/data/state/post/models/post.dart';
import 'package:monami/src/data/state/user_info/models/user_info_model.dart';
import 'package:monami/src/presentation/views/components/animation/models/small_error_animation.dart';
import 'package:monami/src/presentation/views/components/rich_text_view.dart';

class PostDisplayNameAndMessageView extends ConsumerWidget {
  final Post post;
  const PostDisplayNameAndMessageView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoModel = ref.watch(authServiceProvider);
    final userId = post.userId;

    return FutureBuilder<UserInfoModel?>(
      future: userInfoModel.authService.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const SmallErrorAnimationView();
        } else if (snapshot.hasData) {
          final userInfoModel = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichTwoPartsText(
              leftPart: "@${userInfoModel.displayName}",
              rightPart: post.message,
            ),
          );
        } else {
          return const SizedBox(); // Placeholder widget if data is not available
        }
      },
    );
  }
}
