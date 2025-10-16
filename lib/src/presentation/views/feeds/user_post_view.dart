// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:lomj/state/post/providers/user_posts_provider.dart';
// import 'package:lomj/views/components/animations/models/empty_content_with_text_animation_view.dart';
// import 'package:lomj/views/components/animations/models/error_animation_view.dart';
// import 'package:lomj/views/components/animations/models/loading_animation_view.dart';
// import 'package:lomj/views/components/post/post_grid_view.dart';
// import 'package:lomj/views/constants/strings.dart';
// import 'package:monami/views/components/animation/models/loadin_animation.dart';
// import 'package:monami/views/constants/strings.dart';

// class UserPostView extends ConsumerWidget {
//   const UserPostView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final posts = ref.watch(userPostProvider);
//     return RefreshIndicator(
//         child: posts.when(data: (posts) {
//           if (posts.isEmpty) {
//             return const EmptyContentAnimationWihText(
//                 text: Strings.youHaveNoPosts);
//           } else {
//             return PostGridView(posts: posts);
//           }
//         }, error: (error, stackTrace) {
//           return const ErrorAnimationView();
//         }, loading: () {
//           return const LoadingAnimationView();
//         }),
//         onRefresh: () {
//           ref.invalidate(userPostProvider);
//           return Future.delayed(const Duration(seconds: 1));
//         });
//   }
// }
