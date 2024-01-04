import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monami/state/post/models/post.dart';
import 'package:monami/views/components/post/post_display_image_and_message_view.dart';

class PostThumbnailView extends StatelessWidget {
  final Post post;
  final VoidCallback onTapped;
  const PostThumbnailView(
      {super.key, required this.post, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
          top: 10,
        ),
        height: 150,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.thumbnailUrl,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostDisplayNameAndMessageView(post: post),
                  Text(post.message, style: GoogleFonts.aboreto()),
                  const Spacer(),
                  Text(DateFormat().format(post.createdAt),
                      style: GoogleFonts.aboreto(color: Colors.grey))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
