import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/data/remote/product_service.dart';
import 'package:monami/src/data/remote/cart_service.dart';
import 'package:monami/src/data/remote/favorites_service.dart';

class EnhancedProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onCartAdded;
  final VoidCallback? onFavoriteToggled;

  const EnhancedProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onCartAdded,
    this.onFavoriteToggled,
  }) : super(key: key);

  @override
  State<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends State<EnhancedProductCard> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();

  bool _isUserProduct = false;
  bool _isInCart = false;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkProductOwnership();
    _checkCartStatus();
    _checkFavoriteStatus();
  }

  Future<void> _checkProductOwnership() async {
    try {
      final isUserProduct =
          await _productService.isUserProduct(widget.product.id);
      if (mounted) {
        setState(() {
          _isUserProduct = isUserProduct;
        });
      }
    } catch (e) {
      print('Error checking product ownership: $e');
    }
  }

  Future<void> _checkCartStatus() async {
    try {
      final cartItems = await _cartService.getCartItems();
      final isInCart =
          cartItems.any((item) => item.productId == widget.product.id);
      if (mounted) {
        setState(() {
          _isInCart = isInCart;
        });
      }
    } catch (e) {
      print('Error checking cart status: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favorites = await _favoritesService.getFavorites();
      final isFavorite = favorites.contains(widget.product.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleCart() async {
    if (_isUserProduct || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isInCart) {
        await _cartService.removeFromCart(widget.product.id);
        setState(() {
          _isInCart = false;
        });
      } else {
        final cartItem = CartItem(
          productId: widget.product.id,
          productName: widget.product.name,
          price: widget.product.price,
          image: widget.product.images.isNotEmpty
              ? widget.product.images.first
              : '',
          quantity: 1,
          color: widget.product.colors.isNotEmpty
              ? widget.product.colors.first
              : '',
          size:
              widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '',
          addedAt: DateTime.now(),
        );
        await _cartService.addToCart(cartItem);
        setState(() {
          _isInCart = true;
        });
      }

      if (widget.onCartAdded != null) {
        widget.onCartAdded!();
      }
    } catch (e) {
      print('Error toggling cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating cart: ${e.toString()}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isUserProduct || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await _favoritesService.removeFromFavorites(widget.product.id);
        setState(() {
          _isFavorite = false;
        });
      } else {
        await _favoritesService.addToFavorites(widget.product.id);
        setState(() {
          _isFavorite = true;
        });
      }

      if (widget.onFavoriteToggled != null) {
        widget.onFavoriteToggled!();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating favorites: ${e.toString()}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
            // Product Image with Overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Image.asset(
                      widget.product.images.isNotEmpty
                          ? widget.product.images.first
                          : 'assets/images/bag_1.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
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

                  // Owner Badge
                  if (_isUserProduct)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Your Product',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Action Buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        // Favorite Button
                        GestureDetector(
                          onTap: _isUserProduct ? null : _toggleFavorite,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isUserProduct
                                        ? Colors.grey.shade400
                                        : (_isFavorite
                                            ? Colors.red
                                            : Colors.grey.shade600),
                                    size: 16,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Cart Button
                        GestureDetector(
                          onTap: _isUserProduct ? null : _toggleCart,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isInCart
                                        ? Icons.shopping_cart
                                        : Icons.add_shopping_cart,
                                    color: _isUserProduct
                                        ? Colors.grey.shade400
                                        : (_isInCart
                                            ? Colors.green
                                            : Colors.grey.shade600),
                                    size: 16,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.product.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        widget.product.description,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < widget.product.rating.floor()
                                  ? Icons.star
                                  : Icons.star_outline,
                              size: 8,
                              color: Colors.orange,
                            );
                          }),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${widget.product.rating} (${widget.product.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Product Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.isAvailable
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        widget.product.isAvailable
                            ? 'Available'
                            : 'Out of Stock',
                        style: GoogleFonts.inter(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: widget.product.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
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
}
