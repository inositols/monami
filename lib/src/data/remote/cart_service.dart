import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/services/storage_service.dart';
import 'package:monami/src/utils/logger.dart';

/// Service to handle cart operations with Firebase and local storage
class CartService {
  final _logger = Logger(CartService);
  final _firestore = FirebaseFirestore.instance;

  /// Add item to cart (both Firebase and local storage)
  Future<void> addToCart(CartItem cartItem) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Add to Firebase
      await _addToFirestoreCart(cartItem, currentUser.uid);

      // Add to local storage
      await StorageService.addToCart(cartItem.toJson());

      _logger.log('Item added to cart: ${cartItem.productName}');
    } catch (e) {
      _logger.log('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Add item to Firebase cart
  Future<void> _addToFirestoreCart(CartItem cartItem, String userId) async {
    try {
      final cartRef = _firestore
          .collection(FirebaseCollectionName.carts)
          .doc('${userId}_${cartItem.productId}');

      await cartRef.set({
        'userId': userId,
        'productId': cartItem.productId,
        'productName': cartItem.productName,
        'price': cartItem.price,
        'image': cartItem.image,
        'quantity': cartItem.quantity,
        'color': cartItem.color,
        'size': cartItem.size,
        'addedAt': cartItem.addedAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.log('Cart item added to Firestore');
    } catch (e) {
      _logger.log('Error adding to Firestore cart: $e');
      throw Exception('Failed to add item to cloud cart: $e');
    }
  }

  /// Get cart items from Firebase
  Future<List<CartItem>> getCartItemsFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.carts)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('addedAt', descending: true)
          .get();

      final cartItems = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CartItem.fromJson(data);
      }).toList();

      _logger.log('Retrieved ${cartItems.length} cart items from Firebase');
      return cartItems;
    } catch (e) {
      _logger.log('Error getting cart items from Firebase: $e');
      throw Exception('Failed to fetch cart items from cloud: $e');
    }
  }

  /// Get cart items (Firebase first, then local fallback)
  Future<List<CartItem>> getCartItems() async {
    try {
      // Try Firebase first
      try {
        final cartItems = await getCartItemsFromFirebase();
        // Sync with local storage
        await _syncCartWithLocal(cartItems);
        return cartItems;
      } catch (firebaseError) {
        _logger
            .log('Firebase error, loading from local storage: $firebaseError');
        // Fallback to local storage
        final cartData = await StorageService.getCartItems();
        return cartData.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      _logger.log('Error getting cart items: $e');
      return [];
    }
  }

  /// Sync Firebase cart with local storage
  Future<void> _syncCartWithLocal(List<CartItem> firebaseCartItems) async {
    try {
      // Clear local cart
      await StorageService.clearCart();

      // Add Firebase items to local storage
      for (final item in firebaseCartItems) {
        await StorageService.addToCart(item.toJson());
      }

      _logger.log(
          'Synced ${firebaseCartItems.length} cart items with local storage');
    } catch (e) {
      _logger.log('Error syncing cart with local storage: $e');
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      // Update in Firebase
      await _firestore
          .collection(FirebaseCollectionName.carts)
          .doc('${currentUser.uid}_$productId')
          .update({
        'quantity': quantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update in local storage
      await StorageService.updateCartItemQuantity(productId, quantity);

      _logger.log('Cart item quantity updated: $productId -> $quantity');
    } catch (e) {
      _logger.log('Error updating cart item quantity: $e');
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Remove from Firebase
      await _firestore
          .collection(FirebaseCollectionName.carts)
          .doc('${currentUser.uid}_$productId')
          .delete();

      // Remove from local storage
      await StorageService.removeFromCart(productId);

      _logger.log('Item removed from cart: $productId');
    } catch (e) {
      _logger.log('Error removing from cart: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Clear from Firebase
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.carts)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear from local storage
      await StorageService.clearCart();

      _logger.log('Cart cleared successfully');
    } catch (e) {
      _logger.log('Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCartItems();
      return cartItems.fold<int>(0, (int sum, item) => sum + item.quantity);
    } catch (e) {
      _logger.log('Error getting cart item count: $e');
      return 0;
    }
  }

  /// Calculate cart total
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCartItems();
      double total = 0.0;
      for (final item in cartItems) {
        // item.totalPrice might be a double or a Future<double>, so wrap with Future.value and await
        final price = await Future.value(item.totalPrice);
        total += price;
      }
      return total;
    } catch (e) {
      _logger.log('Error calculating cart total: $e');
      return 0.0;
    }
  }

  /// Check if product is in cart
  Future<bool> isInCart(String productId) async {
    try {
      final cartItems = await getCartItems();
      return cartItems.any((item) => item.productId == productId);
    } catch (e) {
      _logger.log('Error checking if product is in cart: $e');
      return false;
    }
  }

  /// Get cart item by product ID
  Future<CartItem?> getCartItem(String productId) async {
    try {
      final cartItems = await getCartItems();
      try {
        return cartItems.firstWhere((item) => item.productId == productId);
      } catch (e) {
        return null;
      }
    } catch (e) {
      _logger.log('Error getting cart item: $e');
      return null;
    }
  }
}




