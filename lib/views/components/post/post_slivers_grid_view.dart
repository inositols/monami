import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/state/post/models/post.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';
import 'model/post_model.dart';

class PostsSliverGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostsSliverGridView({
    super.key,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: posts.length,
        (context, index) {
          final post = posts.elementAt(index);
          return SizedBox(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: 200,
                        decoration: const BoxDecoration(
                            color: AppColor.bgColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          child: Image.asset(discoverList[index].image),
                        ),
                      ),
                      Positioned(
                          top: 10,
                          right: 20,
                          child: Stack(
                            children: [
                              Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(40))),
                              Positioned(
                                top: -6.5,
                                right: -9,
                                child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.red)),
                              )
                            ],
                          )),
                    ],
                  ),
                  Text(discoverList[index].title,
                      style: GoogleFonts.allan(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('\$${discoverList[index].price}',
                      style: GoogleFonts.allan(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.bgColor))
                ],
              ));
          // PostThumbnailView(
          //   post: post,
          //   onTapped: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => PostDetailsView(
          //           post: post,
          //         ),
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
  }
}
