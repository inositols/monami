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
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';

import 'dart:developer' as devtools show log;

import '../product/product_detail_view.dart';
import '../../../models/product_model.dart';
import '../../../services/storage_service.dart';
import '../../../data/remote/product_service.dart';
import '../../../data/remote/cart_service.dart';
import '../../../data/remote/favorites_service.dart';
import '../../../presentation/widgets/enhanced_product_card.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

// Add a global key to access the home view state
final GlobalKey<_HomeViewState> homeViewKey = GlobalKey<_HomeViewState>();

class _HomeViewState extends ConsumerState<HomeView> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedPriceRange = 'All';
  double minPrice = 0.0;
  double maxPrice = 1000.0;
  
  final TextEditingController _searchController = TextEditingController();
  
  // Services
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();
  
  // Centralized services
  late final NavigationService _navigationService = locator<NavigationService>();
  late final SnackbarHandler _snackbarHandler = locator<SnackbarHandler>();
  late final LocalCache _localCache = locator<LocalCache>();
  late final AuthService _authService = locator<AuthService>();
  
  // Available categories
  final List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports & Fitness',
    'Books',
    'Beauty & Health',
    'Toys & Games',
    'Automotive',
    'Food & Beverages',
    'Other'
  ];
  
  // Price ranges
  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'All', 'min': 0.0, 'max': 10000.0},
    {'label': 'Under \$25', 'min': 0.0, 'max': 25.0},
    {'label': '\$25 - \$50', 'min': 25.0, 'max': 50.0},
    {'label': '\$50 - \$100', 'min': 50.0, 'max': 100.0},
    {'label': '\$100 - \$200', 'min': 100.0, 'max': 200.0},
    {'label': 'Over \$200', 'min': 200.0, 'max': 10000.0},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final productService = ProductService();
      
      // Try to load from Firebase first, then fallback to local storage
      try {
        products = await productService.getProductsFromFirebase();
        // Sync with local storage for offline access
        await productService.syncLocalProductsWithFirebase();
      } catch (firebaseError) {
        print('Firebase error, loading from local storage: $firebaseError');
        // Fallback to local storage if Firebase fails
        final productsData = await StorageService.getProducts();
        products = productsData.map((data) => Product.fromJson(data)).toList();
      }
      
      // Initialize filtered products
      filteredProducts = List.from(products);
    } catch (e) {
      print('Error loading products: $e');
      // Handle error - products list will remain empty
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Public method to refresh products from external calls
  void refreshProducts() {
    setState(() {
      isLoading = true;
    });
    _loadProducts();
  }

  // Navigate to product details
  void _navigateToProductDetail(Product product) {
    _navigationService.pushNamed(
      Routes.productDetailRoute,
      arguments: {
        'image': product.images.isNotEmpty ? product.images.first : 'assets/images/bag_1.png',
        'title': product.name,
        'subtitle': product.description,
        'price': '\$${product.price.toStringAsFixed(2)}',
        'rating': product.rating,
        'reviews': product.reviewCount,
        'productId': product.id,
      },
    );
  }

  // Filter products based on search query, category, and price range
  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        // Search filter
        bool matchesSearch = searchQuery.isEmpty ||
            product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(searchQuery.toLowerCase());

        // Category filter
        bool matchesCategory = selectedCategory == 'All' ||
            product.category == selectedCategory;

        // Price range filter
        bool matchesPrice = true;
        if (selectedPriceRange != 'All') {
          final priceRange = priceRanges.firstWhere(
            (range) => range['label'] == selectedPriceRange,
            orElse: () => {'min': 0.0, 'max': 10000.0},
          );
          matchesPrice = product.price >= priceRange['min'] &&
              product.price <= priceRange['max'];
        }

        return matchesSearch && matchesCategory && matchesPrice;
      }).toList();
    });
  }

  // Handle search input
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterProducts();
  }

  // Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'All';
                        selectedPriceRange = 'All';
                      });
                      _filterProducts();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Filter
                    Text(
                      'Category',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF667EEA)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price Range Filter
                    Text(
                      'Price Range',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: priceRanges.map((range) {
                        final isSelected = selectedPriceRange == range['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPriceRange = range['label'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF667EEA)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              range['label'],
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _filterProducts();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search any Product...",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : Icon(Icons.mic, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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
                      isLoading 
                          ? "Loading..." 
                          : "${filteredProducts.length} Items${searchQuery.isNotEmpty || selectedCategory != 'All' || selectedPriceRange != 'All' ? ' (Filtered)' : ''}",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
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
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : filteredProducts.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  searchQuery.isNotEmpty || selectedCategory != 'All' || selectedPriceRange != 'All'
                                      ? Icons.search_off
                                      : Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty || selectedCategory != 'All' || selectedPriceRange != 'All'
                                      ? 'No Products Found'
                                      : 'No Products Available',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchQuery.isNotEmpty || selectedCategory != 'All' || selectedPriceRange != 'All'
                                      ? 'Try adjusting your search or filters'
                                      : 'Create products from the profile section',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                if (searchQuery.isNotEmpty || selectedCategory != 'All' || selectedPriceRange != 'All') ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        searchQuery = '';
                                        selectedCategory = 'All';
                                        selectedPriceRange = 'All';
                                        _searchController.clear();
                                      });
                                      _filterProducts();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667EEA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Clear Filters',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              return EnhancedProductCard(
                                product: product,
                                onTap: () => _navigateToProductDetail(product),
                                onCartAdded: () {
                                  // Refresh cart count if needed
                                },
                                onFavoriteToggled: () {
                                  // Refresh favorites if needed
                                },
                              );
                            },
                            childCount: filteredProducts.length,
                          ),
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
    required Product product,
  }) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
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
                    product.images.isNotEmpty
                        ? product.images.first
                        : 'assets/images/bag_1.png',
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
                      product.name,
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
                        product.description,
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
                      '\$${product.price.toStringAsFixed(2)}',
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
                                index < product.rating.floor()
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
                              '${product.rating} (${product.reviewCount.toString().length > 4 ? "${(product.reviewCount / 1000).toStringAsFixed(1)}k" : product.reviewCount})',
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
