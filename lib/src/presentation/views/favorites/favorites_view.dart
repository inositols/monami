import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/presentation/views/favorites/widget/empty.dart';
import 'package:monami/src/presentation/views/favorites/widget/header.dart';
import 'package:monami/src/data/remote/favorites_service.dart';
import 'package:monami/src/data/remote/product_service.dart';
import '../../../models/product_model.dart';
import '../../../services/storage_service.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Product> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _loadFavorites();
    _animationController.forward();
  }

  Future<void> _loadFavorites() async {
    try {
      final favoritesService = FavoritesService();
      final productService = ProductService();
      
      // Get favorite IDs from FavoritesService (Firebase + local)
      final favoriteIds = await favoritesService.getFavorites();
      
      // Get products from Firebase first, then fallback to local
      List<Product> allProducts = [];
      try {
        allProducts = await productService.getProductsFromFirebase();
      } catch (firebaseError) {
        print('Firebase error, loading from local storage: $firebaseError');
        // Fallback to local storage
        final productsData = await StorageService.getProducts();
        allProducts = productsData.map((data) => Product.fromJson(data)).toList();
      }

      // Filter products that are in favorites
      favoriteProducts = allProducts
          .where((product) => favoriteIds.contains(product.id))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      // Handle error - favorites list will remain empty
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Your Favorites',
                    icon: Icons.favorite,
                    items: favoriteProducts,
                    isLoading: isLoading,
                    itemLabel: "items in your wishlist",
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : favoriteProducts.isEmpty
                            ? EmptyState(
                                slideAnimation: _slideAnimation,
                                icon: Icons.favorite_border,
                                iconColor: const Color(0xFF667EEA),
                                title: 'No Favorites Yet',
                                subtitle:
                                    'Start exploring and add items\nto your favorites list',
                                onButtonTap: () {
                                  // Navigate to shop/explore
                                })
                            : _buildFavoritesList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return SlideTransition(
      position: _slideAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          return _buildFavoriteItem(favoriteProducts[index], index);
        },
      ),
    );
  }

  Widget _buildFavoriteItem(Product product, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOut.transform(
          ((_animationController.value - delay).clamp(0.0, 1.0) / (1.0 - delay))
              .clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Product Image
                    Hero(
                      tag: 'favorite_${product.id}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            product.images.isNotEmpty
                                ? product.images.first
                                : 'assets/images/bag_1.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A202C),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Rating
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.orange.shade400,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A5568),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviewCount})',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Price
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF667EEA),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Stock Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.isAvailable ? 'In Stock' : 'Out of Stock',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: product.isAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              final favoritesService = FavoritesService();
                              await favoritesService.removeFromFavorites(product.id);
                              await _loadFavorites(); // Reload favorites
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Removed from favorites',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error removing from favorites: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error removing from favorites',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: product.isAvailable
                              ? () async {
                                  final cartItem = {
                                    'productId': product.id,
                                    'productName': product.name,
                                    'price': product.price,
                                    'image': product.images.isNotEmpty
                                        ? product.images.first
                                        : 'assets/images/bag_1.png',
                                    'quantity': 1,
                                    'addedAt': DateTime.now().toIso8601String(),
                                  };

                                  await StorageService.addToCart(cartItem);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added to cart!',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        backgroundColor: Colors.green.shade400,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? const Color(0xFF667EEA).withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: product.isAvailable
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
