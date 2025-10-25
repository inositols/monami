import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/data/remote/cart_service.dart';
import 'package:monami/src/data/remote/favorites_service.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/presentation/widgets/rating_widget.dart';
import 'package:monami/src/presentation/widgets/reviews_list_widget.dart';
import '../../../services/storage_service.dart';

class ProductDetailView extends StatefulWidget {
  final String image;
  final String title;
  final String subtitle;
  final String price;
  final double rating;
  final int reviews;
  final String productId;

  const ProductDetailView({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView>
    with TickerProviderStateMixin {
  int quantity = 1;
  bool isFavorite = false;
  bool isLoadingFavoriteStatus = true;
  int selectedColorIndex = 0;
  int selectedSizeIndex = 1;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late TabController _tabController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Rating state
  double _currentRating = 0.0;
  int _reviewCount = 0;

  final List<Color> colors = [
    const Color(0xFF2D3748),
    const Color(0xFF667EEA),
    const Color(0xFFE53E3E),
    const Color(0xFF38A169),
    const Color(0xFFED8936),
  ];

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);

    // Initialize rating state
    _currentRating = widget.rating;
    _reviewCount = widget.reviews;

    _loadFavoriteStatus();

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _fadeController.forward();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final favoritesService = FavoritesService();
      final favoriteStatus =
          await favoritesService.isFavorite(widget.productId);
      setState(() {
        isFavorite = favoriteStatus;
        isLoadingFavoriteStatus = false;
      });
    } catch (e) {
      setState(() {
        isLoadingFavoriteStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Handle rating updates
  void _onRatingUpdated(double rating, String? review) {
    setState(() {
      _currentRating = rating;
      if (rating > 0) {
        _reviewCount = _reviewCount + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top half with image and overlay buttons
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8FAFC),
                          Color(0xFFE2E8F0),
                        ],
                      ),
                    ),
                  ),
                  
                  // Product Image
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Hero(
                        tag: widget.image,
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667EEA).withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    widget.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey.shade400,
                                          size: 80,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Back button
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF2D3748), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  
                  // Favorite button
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : const Color(0xFF2D3748),
                          size: 20,
                        ),
                        onPressed: () async {
                          if (isLoadingFavoriteStatus) return;

                          try {
                            final favoritesService = FavoritesService();
                            final newFavoriteStatus = await favoritesService
                                .toggleFavorite(widget.productId);

                            setState(() {
                              isFavorite = newFavoriteStatus;
                            });

                            if (mounted) {
                              SnackbarHandlerImpl().showSnackbar(
                                isFavorite
                                    ? 'Added to favorites!'
                                    : 'Removed from favorites',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Added to favorites!'
                                        : 'Removed from favorites',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: isFavorite
                                      ? Colors.red.shade400
                                      : const Color(0xFF718096),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error toggling favorite: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error updating favorites',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom half with content
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Product Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A202C),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF718096),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.reviews})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price and Discount
                  Row(
                    children: [
                      Text(
                        widget.price,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF667EEA),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '25% OFF',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Color Selection
                  Text(
                    'Available Colors',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: colors.asMap().entries.map((entry) {
                        int index = entry.key;
                        Color color = entry.value;
                        bool isSelected = selectedColorIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColorIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 16),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 24)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Size Selection
                  Text(
                    'Select Size',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sizes.asMap().entries.map((entry) {
                        int index = entry.key;
                        String size = entry.value;
                        bool isSelected = selectedSizeIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSizeIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 12),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    )
                                  : null,
                              color:
                                  isSelected ? null : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: const Color(0xFF667EEA)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF4A5568),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quantity and Add to Cart
                  Row(
                    children: [
                      // Quantity Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A202C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: quantity > 1
                                          ? const Color(0xFF667EEA)
                                          : const Color(0xFFF7FAFC),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: quantity > 1
                                          ? Colors.white
                                          : const Color(0xFFA0AEC0),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(
                                      quantity.toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A202C),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF667EEA),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Add to Cart Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add to Cart',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A202C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: GestureDetector(
                                    onTap: () async {
                                      try {
                                        final cartItem = CartItem(
                                          productId: widget.productId,
                                          productName: widget.title,
                                          price: double.parse(widget.price
                                              .replaceAll('\$', '')),
                                          image: widget.image,
                                          quantity: quantity,
                                          color: colors.isNotEmpty
                                              ? colors[selectedColorIndex]
                                                  .toString()
                                                  .split('(')
                                                  .last
                                                  .split(')')
                                                  .first
                                              : null,
                                          size: sizes.isNotEmpty
                                              ? sizes[selectedSizeIndex]
                                              : null,
                                          addedAt: DateTime.now(),
                                        );

                                        final cartService = CartService();
                                        await cartService.addToCart(cartItem);

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Added $quantity ${quantity == 1 ? 'item' : 'items'} to cart!',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              backgroundColor:
                                                  const Color(0xFF38A169),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error adding to cart',
                                                style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              backgroundColor:
                                                  Colors.red.shade400,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667EEA),
                                            Color(0xFF764BA2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667EEA)
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Add to Cart',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Premium Description
                  Text(
                    'Product Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      'Experience luxury with this premium quality product, meticulously crafted with attention to detail. Made from high-grade materials that ensure exceptional durability and comfort. Features modern design aesthetics perfect for contemporary lifestyles. Suitable for both casual and formal occasions.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A5568),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Premium Features
                  Text(
                    'Why Choose This?',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                      Icons.verified_outlined, 'Premium Quality Materials'),
                  _buildFeatureItem(
                      Icons.local_shipping_outlined, 'Free Shipping & Returns'),
                  _buildFeatureItem(Icons.security_outlined, '2 Year Warranty'),
                  _buildFeatureItem(
                      Icons.eco_outlined, 'Sustainable & Eco-Friendly'),

                  const SizedBox(height: 32),

                  // Rating and Reviews Section
                  Text(
                    'Rating & Reviews',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating Widget
                  RatingWidget(
                    productId: widget.productId,
                    currentRating: _currentRating,
                    reviewCount: _reviewCount,
                    onRatingSubmitted: _onRatingUpdated,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reviews List
                  ReviewsListWidget(
                    productId: widget.productId,
                    limit: 5,
                  ),

                  const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
