import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/presentation/widgets/custom_button.dart';
import 'package:monami/src/presentation/widgets/custom_textfield.dart';
// Temporarily disabled for web compatibility
// import 'package:monami/src/features/image_upload/helpers/image_upload_helper.dart';
// import 'package:monami/src/features/image_upload/models/file_type.dart';
// import 'package:monami/src/data/state/post_settings/providers/post_settings_provider.dart';
import 'package:monami/src/utils/constants/app_colors.dart';
import 'package:monami/src/utils/constants/app_images.dart';

import 'dart:developer' as devtools show log;

import '../product/product_detail_view.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with Profile and Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child:
                              const Icon(Icons.menu, color: Color(0xFF2D3748)),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Monami",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.5),
                        child: Image.asset(
                          'assets/images/woman.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                color: Color(0xFF2D3748));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextfield(
                    hintText: "Search any Product...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    suffixIcon: Icon(Icons.mic, color: Colors.grey.shade400),
                    fillColor: Colors.white,
                    hasBorderside: false,
                  ),
                ),
              ),
            ),

            // Items Count and Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "52,082+ Items",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Sort",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.swap_vert,
                                  size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Filter",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.tune,
                                  size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _buildProductCard(
                    image: 'assets/images/bag_1.png',
                    title: 'Black Winter...',
                    subtitle:
                        'Autumn And Winter Casual cotton-padded jacket...',
                    price: '₹499',
                    rating: 4.2,
                    reviews: 2356,
                  ),
                  _buildProductCard(
                    image: 'assets/images/cap_1.png',
                    title: 'Mens Starry',
                    subtitle:
                        'Mens Starry Sky Printed Shirt 100% Cotton Fabric',
                    price: '₹399',
                    rating: 4.8,
                    reviews: 1024,
                  ),
                  _buildProductCard(
                    image: 'assets/images/womanshoe_3.png',
                    title: 'Black Dress',
                    subtitle:
                        'Solid Black Dress for Women, Sexy Chain Shorts Ladi...',
                    price: '₹2,000',
                    rating: 4.1,
                    reviews: 5647,
                  ),
                  _buildProductCard(
                    image: 'assets/images/bag_2.png',
                    title: 'Pink Embroide...',
                    subtitle: 'EARTHEN Rose Pink Embroidered Tiered Midi Dr...',
                    price: '₹1,900',
                    rating: 4.9,
                    reviews: 3274,
                  ),
                  _buildProductCard(
                    image: 'assets/images/ring_2.png',
                    title: 'Flare Dress',
                    subtitle:
                        'Antheaa Black & Rust Orange Flare Dress Tiered Midi F...',
                    price: '₹1,990',
                    rating: 4.3,
                    reviews: 1205,
                  ),
                  _buildProductCard(
                    image: 'assets/images/cap_3.png',
                    title: 'denim dress',
                    subtitle:
                        'Blue colour, denim dress Look 2 Pieces cotton dr...',
                    price: '₹999',
                    rating: 4.7,
                    reviews: 2341,
                  ),
                  _buildProductCard(
                    image: 'assets/images/shoeman_7.png',
                    title: 'Jordan Stay',
                    subtitle:
                        'The classic Air Jordan 13 is made to create a shoe that\'s fre...',
                    price: '₹6,999',
                    rating: 4.6,
                    reviews: 1245,
                  ),
                  _buildProductCard(
                    image: 'assets/images/headphone_6.png',
                    title: 'Realme 7',
                    subtitle: 'GST 8MP | 16 GB ROM | Expandable Upto 256...',
                    price: '₹3,699',
                    rating: 4.2,
                    reviews: 5467,
                  ),
                  _buildProductCard(
                    image: 'assets/images/bag_4.png',
                    title: 'Black Jacket 12...',
                    subtitle:
                        'This warm and comfortable jacket is great for learn...',
                    price: '₹2,999',
                    rating: 4.5,
                    reviews: 1342,
                  ),
                  _buildProductCard(
                    image: 'assets/images/womanshoe_5.png',
                    title: 'men\'s & boys s...',
                    subtitle: 'George Walker Derby Brown Formal Shoes',
                    price: '₹999',
                    rating: 4.0,
                    reviews: 2156,
                  ),
                ]),
              ),
            ),

            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String image,
    required String title,
    required String subtitle,
    required String price,
    required double rating,
    required int reviews,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailView(
              image: image,
              title: title,
              subtitle: subtitle,
              price: price,
              rating: rating,
              reviews: reviews,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : Icons.star_outline,
                                size: 10,
                                color: Colors.orange,
                              );
                            }),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '$rating (${reviews.toString().length > 4 ? "${(reviews / 1000).toStringAsFixed(1)}k" : reviews})',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.red : Colors.grey.shade600,
          size: 24,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.red : Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
