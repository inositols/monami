// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:monami/views/components/post/model/post_model.dart';

// import '../../../state/post/models/post.dart';
// import '../../onboarding/components/constants/app_color.dart';

// class PostThumbnailView extends StatelessWidget {
//   final Post post;
//   final VoidCallback onTapped;
//   const PostThumbnailView(
//       {super.key, required this.post, required this.onTapped});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTapped,
//       child: SizedBox(
//           height: 200,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     width: double.maxFinite,
//                     height: 200,
//                     decoration: const BoxDecoration(
//                         color: AppColor.bgColor,
//                         borderRadius: BorderRadius.all(Radius.circular(15))),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(15)),
//                       child: Image.asset(discoverList[i].image),
//                     ),
//                   ),
//                   Positioned(
//                       top: 10,
//                       right: 20,
//                       child: Stack(
//                         children: [
//                           Container(
//                               height: 30,
//                               width: 30,
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(40))),
//                           Positioned(
//                             top: -6.5,
//                             right: -9,
//                             child: IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(Icons.favorite,
//                                     color: Colors.red)),
//                           )
//                         ],
//                       )),
//                 ],
//               ),
//               Text(discoverList[i].title,
//                   style: GoogleFonts.allan(
//                       fontSize: 20, fontWeight: FontWeight.bold)),
//               Text('\$${discoverList[i].price}',
//                   style: GoogleFonts.allan(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColor.bgColor))
//             ],
//           )),
//     );
//   }
// }
