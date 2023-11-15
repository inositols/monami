import 'package:flutter/material.dart';
import 'package:monami/state/post/models/post.dart';

class PostThumbnailView extends StatelessWidget {
  final Post post;
  final VoidCallback onTapped;
  const PostThumbnailView(
      {super.key, required this.post, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Image.network(
        post.thumbnailUrl,
        fit: BoxFit.contain,
      ),
    );
  }
}
