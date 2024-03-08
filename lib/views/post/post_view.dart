import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/state/post/models/post.dart';
import 'package:monami/views/components/post/model/post_model.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

import 'post_description.dart';

class PostGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostGridView({
    super.key,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: posts.length,
      padding: const EdgeInsets.fromLTRB(15, 0, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 0.65),
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailsView(
                  post: post,
                ),
              ),
            );
          },
          child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: 200,
                        decoration: BoxDecoration(
                            color: AppColor.grey400,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          child: Image.network(
                            post.thumbnailUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(discoverList[index].title,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  Text('\$${discoverList[index].price}',
                      style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))
                ],
              )),
        );
      },
    );
  }
}
