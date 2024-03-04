import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/views/components/post/model/post_model.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

class PostGridView extends StatelessWidget {
  // final Iterable<Post> posts;
  const PostGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: discoverList.length,
      padding: const EdgeInsets.fromLTRB(15, 0, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 0.65),
      itemBuilder: (context, index) {
        // final post = posts.elementAt(index);
        return Container(
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
                        child: Image.asset(discoverList[index].image),
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
            ));
      },
    );
  }
}
