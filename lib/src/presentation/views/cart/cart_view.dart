import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/presentation/views/favorites/widget/empty.dart';
import 'package:monami/src/data/remote/cart_service.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';
import 'widget/cart.dart';

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<CartItem> cartItems = [];
  bool isLoading = true;

  // Centralized services
  late final NavigationService _navigationService =
      locator<NavigationService>();
  late final SnackbarHandler _snackbarHandler = locator<SnackbarHandler>();
  late final LocalCache _localCache = locator<LocalCache>();
  late final AuthService _authService = locator<AuthService>();

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get shipping => subtotal > 100 ? 0 : 10.99;
  double get tax => subtotal * 0.08;
  double get total => subtotal + shipping + tax;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _loadCartItems();
    _animationController.forward();
  }

  Future<void> _loadCartItems() async {
    try {
      final cartService = CartService();

      // Try to load from Firebase first, then fallback to local storage
      try {
        cartItems = await cartService.getCartItems();
      } catch (firebaseError) {
        print('Firebase error, loading from local storage: $firebaseError');
        // Fallback to local storage if Firebase fails
        final cartData = await StorageService.getCartItems();
        cartItems = cartData.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading cart items: $e');
      // Handle error - cart items list will remain empty
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
                      title: "Shopping Cart",
                      icon: Icons.shopping_cart,
                      items: cartItems,
                      isLoading: isLoading,
                      itemLabel: "items in your cart"),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : cartItems.isEmpty
                            ? EmptyState(
                                slideAnimation: _slideAnimation,
                                icon: Icons.shopping_cart_outlined,
                                iconColor: const Color(0xFF667EEA),
                                title: "Your cart is empty",
                                subtitle:
                                    "Browse products and add them to your cart.",
                                onButtonTap: () {},
                              )
                            : _buildCartContent(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItemWidget(
                  _animationController,
                  item: cartItems[index],
                  index: index,
                  removeCart: () async {
                    try {
                      final cartService = CartService();
                      await cartService
                          .removeFromCart(cartItems[index].productId);
                      await _loadCartItems(); // Reload cart
                      if (mounted) {
                        _snackbarHandler.showSnackbar("Item removed from cart");
                      }
                    } catch (e) {
                      print('Error removing from cart: $e');
                      if (mounted) {
                        _snackbarHandler
                            .showErrorSnackbar("Error removing item from cart");
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
        OrderSummaryWidget(
            subtotal: subtotal,
            tax: tax,
            total: total,
            shipping: shipping,
            onPressed: () async {
              Orders order = Orders(
                id: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
                items: cartItems,
                subtotal: subtotal,
                shipping: shipping,
                tax: tax,
                total: total,
                status: 'pending',
                createdAt: DateTime.now(),
                shippingAddress: {
                  'street': '123 Main St',
                  'city': 'City',
                  'country': 'Country',
                },
                paymentMethod: 'paystack',
              );

              final result = await _navigationService.pushNamed(
                Routes.paymentRoute,
                arguments: {
                  'order': order,
                  'items': cartItems,
                },
              );

              if (result == true) {
                await _localCache.clearCart();
                await _loadCartItems();
              }
            }),
      ],
    );
  }
}
