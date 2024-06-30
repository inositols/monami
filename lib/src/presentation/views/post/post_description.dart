import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/enums/dart_sorting.dart';
import 'package:monami/src/features/comments/models/posts_comment_request.dart';
import 'package:monami/src/data/state/post/models/post.dart';

import 'package:monami/src/data/state/post/providers/specific_with_comment.dart';
import 'package:monami/src/presentation/views/components/animation/models/error_animation.dart';
import 'package:monami/src/presentation/views/components/comments/compact_column_comment.dart';
import 'package:monami/src/presentation/views/components/likes/likes_button.dart';
import 'package:monami/src/presentation/views/components/likes/likes_count_view.dart';
import 'package:monami/src/presentation/views/components/post/post_date_view.dart';
import 'package:monami/src/presentation/views/components/post/post_display_image_and_message_view.dart';
import 'package:monami/src/presentation/views/components/post/post_imageor_video.dart';

import 'package:monami/src/presentation/views/post/post_comments_view.dart';
import 'package:monami/src/utils/constants/app_string.dart';
import '../components/animation/models/loadin_animation.dart';

class PostDetailsView extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailsView({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsViewState();
}

class _PostDetailsViewState extends ConsumerState<PostDetailsView> {
  @override
  Widget build(BuildContext context) {
    final request = RequestForPostAndComments(
      postId: widget.post.postId,
      limit: 2, // at most 3 comments
      sortByCreatedAt: true,
      dateSorting: DateSorting.oldestOnTop,
    );

    // get the actual post together with its comments
    final postWithComments = ref.watch(
      specificPostWithCommentsProvider(
        request,
      ),
    );
    return Scaffold(
      body: postWithComments.when(
        data: (postWithComments) {
          final postId = postWithComments.post.postId;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 70,
                  margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
                  color: Colors.purple.shade900,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.arrow_back_ios)),
                      const Text(
                        Strings.postDetails,
                      ),
                      if (postWithComments.post.allowsLikes)
                        LikeButton(
                          postId: postId,
                        ),
                    ],
                  ),
                ),

                InkWell(
                  onTap: () {
                    print("object");
                  },
                  child: PostImageOrVideoView(
                    post: postWithComments.post,
                  ),
                ),
                // like and comment buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // like button if post allows liking it
                    if (postWithComments.post.allowsLikes)
                      LikeButton(
                        postId: postId,
                      ),
                    // comment button if post allows commenting on it
                    if (postWithComments.post.allowsComments)
                      IconButton(
                        icon: const Icon(
                          Icons.mode_comment_outlined,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostCommentsView(
                                postId: postId,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                // post details (shows divider at bottom)
                PostDisplayNameAndMessageView(
                  post: postWithComments.post,
                ),
                PostDateView(
                  dateTime: postWithComments.post.createdAt,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(
                    color: Colors.white70,
                  ),
                ),
                // comments
                // CompactCommentsColumn(
                //   comments: postWithComments.comments,
                // ),
                // display like count
                if (postWithComments.post.allowsLikes)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        LikesCountView(
                          postId: postId,
                        ),
                      ],
                    ),
                  ),
                // add spacing to bottom of screen
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return const ErrorAnimationView();
        },
        loading: () {
          return const LoadingAnimationView();
        },
      ),
    );
  }
}
