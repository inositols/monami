import 'package:flutter/material.dart';

import 'package:monami/state/post/models/post.dart';
import 'package:monami/views/components/post/post_thumbnail.dart';

import 'post_description.dart';

class PostGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostGridView({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.only(left: 10),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts.elementAt(index);
          return PostThumbnailView(
              post: post,
              onTapped: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsView(
                      post: post,
                    ),
                  ),
                );
              });
        },
        separatorBuilder: (context, index) =>
            const Text("🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"));
  }
}
