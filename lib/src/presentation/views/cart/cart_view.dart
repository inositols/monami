import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/presentation/views/favorites/widget/empty.dart';
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
      final cartData = await StorageService.getCartItems();
      cartItems = cartData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      // Handle error
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
                    await StorageService.removeFromCart(
                        cartItems[index].productId);
                    await _loadCartItems(); // Reload cart
                    if (mounted) {
                      SnackbarHandlerImpl()
                          .showSnackbar("Item removed from cart");
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutView(
                  items: cartItems
                      .map((item) => CheckoutItem(
                            id: int.parse(item.productId),
                            name: item.productName,
                            price: item.price,
                            quantity: item.quantity,
                            image: item.image,
                          ))
                      .toList(),
                  subtotal: subtotal,
                  shipping: shipping,
                  tax: tax,
                ),
              ),
            );

            // If checkout was successful, clear cart and reload
            if (result == true) {
              await StorageService.clearCart();
              await _loadCartItems();
            }
          },
        ),
      ],
    );
  }
}
