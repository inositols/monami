import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _productsKey = 'products';
  static const String _favoritesKey = 'favorites';
  static const String _cartKey = 'cart';
  static const String _ordersKey = 'orders';
  static const String _userProfileKey = 'user_profile';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          'StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  // Product management
  static Future<List<Map<String, dynamic>>> getProducts() async {
    await init();
    final String? productsJson = prefs.getString(_productsKey);
    if (productsJson == null) return [];

    final List<dynamic> productsList = jsonDecode(productsJson);
    return productsList.cast<Map<String, dynamic>>();
  }

  static Future<void> saveProduct(Map<String, dynamic> product) async {
    await init();
    final products = await getProducts();

    // Generate ID if not provided
    if (product['id'] == null) {
      product['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    products.add(product);
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  static Future<void> updateProduct(Map<String, dynamic> updatedProduct) async {
    await init();
    final products = await getProducts();
    final index = products.indexWhere((p) => p['id'] == updatedProduct['id']);

    if (index != -1) {
      products[index] = updatedProduct;
      await prefs.setString(_productsKey, jsonEncode(products));
    }
  }

  static Future<void> deleteProduct(String productId) async {
    await init();
    final products = await getProducts();
    products.removeWhere((p) => p['id'] == productId);
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  // Favorites management
  static Future<List<String>> getFavorites() async {
    await init();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> addToFavorites(String productId) async {
    await init();
    final favorites = await getFavorites();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  static Future<void> removeFromFavorites(String productId) async {
    await init();
    final favorites = await getFavorites();
    favorites.remove(productId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  // Cart management
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    await init();
    final String? cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> cartList = jsonDecode(cartJson);
    return cartList.cast<Map<String, dynamic>>();
  }

  static Future<void> addToCart(Map<String, dynamic> cartItem) async {
    await init();
    final cartItems = await getCartItems();

    // Check if item already exists
    final existingIndex = cartItems
        .indexWhere((item) => item['productId'] == cartItem['productId']);

    if (existingIndex != -1) {
      // Update quantity
      cartItems[existingIndex]['quantity'] = cartItem['quantity'];
    } else {
      // Add new item
      cartItems.add(cartItem);
    }

    await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  static Future<void> removeFromCart(String productId) async {
    await init();
    final cartItems = await getCartItems();
    cartItems.removeWhere((item) => item['productId'] == productId);
    await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  static Future<void> updateCartItemQuantity(
      String productId, int quantity) async {
    await init();
    final cartItems = await getCartItems();
    final index =
        cartItems.indexWhere((item) => item['productId'] == productId);

    if (index != -1) {
      if (quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index]['quantity'] = quantity;
      }
      await prefs.setString(_cartKey, jsonEncode(cartItems));
    }
  }

  static Future<void> clearCart() async {
    await init();
    await prefs.remove(_cartKey);
  }

  // Orders management
  static Future<List<Map<String, dynamic>>> getOrders() async {
    await init();
    final String? ordersJson = prefs.getString(_ordersKey);
    if (ordersJson == null) return [];

    final List<dynamic> ordersList = jsonDecode(ordersJson);
    return ordersList.cast<Map<String, dynamic>>();
  }

  static Future<void> saveOrder(Map<String, dynamic> order) async {
    await init();
    final orders = await getOrders();

    // Generate order ID if not provided
    if (order['id'] == null) {
      order['id'] = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    }

    // Add timestamp
    order['createdAt'] = DateTime.now().toIso8601String();

    orders.insert(0, order); // Add to beginning for recent first
    await prefs.setString(_ordersKey, jsonEncode(orders));
  }

  // User profile management
  static Future<Map<String, dynamic>?> getUserProfile() async {
    await init();
    final String? profileJson = prefs.getString(_userProfileKey);
    if (profileJson == null) return null;

    return jsonDecode(profileJson);
  }

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await init();
    await prefs.setString(_userProfileKey, jsonEncode(profile));
  }

  // Utility methods
  static Future<void> clearAllData() async {
    await init();
    await prefs.clear();
  }

  static Future<void> exportData() async {
    await init();
    final data = {
      'products': await getProducts(),
      'favorites': await getFavorites(),
      'cart': await getCartItems(),
      'orders': await getOrders(),
      'profile': await getUserProfile(),
    };

    // In a real app, you might want to save this to a file or send to a server
    print('Exported data: ${jsonEncode(data)}');
  }
}
