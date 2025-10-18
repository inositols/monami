import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/services/storage_service.dart';
import 'package:monami/src/utils/logger.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:monami/src/data/remote/product_service.dart';

/// Service to handle favorites operations with Firebase and local storage
class FavoritesService {
  final _logger = Logger(FavoritesService);
  final _firestore = FirebaseFirestore.instance;

  /// Add product to favorites (both Firebase and local storage)
  Future<void> addToFavorites(String productId) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Add to Firebase
      await _addToFirestoreFavorites(productId, currentUser.uid);

      // Add to local storage
      await StorageService.addToFavorites(productId);

      // Send notification to product owner
      await _sendLikeNotification(productId, currentUser.uid);

      _logger.log('Product added to favorites: $productId');
      print('DEBUG: Like notification trigger called for product: $productId');
    } catch (e) {
      _logger.log('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Add product to Firebase favorites
  Future<void> _addToFirestoreFavorites(String productId, String userId) async {
    try {
      final favoriteRef = _firestore
          .collection(FirebaseCollectionName.favorites)
          .doc('${userId}_$productId');

      await favoriteRef.set({
        'userId': userId,
        'productId': productId,
        'addedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.log('Favorite added to Firestore');
    } catch (e) {
      _logger.log('Error adding to Firestore favorites: $e');
      throw Exception('Failed to add favorite to cloud: $e');
    }
  }

  /// Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Remove from Firebase
      await _firestore
          .collection(FirebaseCollectionName.favorites)
          .doc('${currentUser.uid}_$productId')
          .delete();

      // Remove from local storage
      await StorageService.removeFromFavorites(productId);

      _logger.log('Product removed from favorites: $productId');
    } catch (e) {
      _logger.log('Error removing from favorites: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Get favorites from Firebase
  Future<List<String>> getFavoritesFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.favorites)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('addedAt', descending: true)
          .get();

      final favorites = querySnapshot.docs
          .map((doc) => doc.data()['productId'] as String)
          .toList();

      _logger.log('Retrieved ${favorites.length} favorites from Firebase');
      return favorites;
    } catch (e) {
      _logger.log('Error getting favorites from Firebase: $e');
      throw Exception('Failed to fetch favorites from cloud: $e');
    }
  }

  /// Get favorites (Firebase first, then local fallback)
  Future<List<String>> getFavorites() async {
    try {
      // Try Firebase first
      try {
        final favorites = await getFavoritesFromFirebase();
        // Sync with local storage
        await _syncFavoritesWithLocal(favorites);
        return favorites;
      } catch (firebaseError) {
        _logger.log('Firebase error, loading from local storage: $firebaseError');
        // Fallback to local storage
        return await StorageService.getFavorites();
      }
    } catch (e) {
      _logger.log('Error getting favorites: $e');
      return [];
    }
  }

  /// Sync Firebase favorites with local storage
  Future<void> _syncFavoritesWithLocal(List<String> firebaseFavorites) async {
    try {
      // Clear local favorites
      final localFavorites = await StorageService.getFavorites();
      for (final favorite in localFavorites) {
        await StorageService.removeFromFavorites(favorite);
      }
      
      // Add Firebase favorites to local storage
      for (final favorite in firebaseFavorites) {
        await StorageService.addToFavorites(favorite);
      }
      
      _logger.log('Synced ${firebaseFavorites.length} favorites with local storage');
    } catch (e) {
      _logger.log('Error syncing favorites with local storage: $e');
    }
  }

  /// Check if product is favorite
  Future<bool> isFavorite(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // If not authenticated, check local storage only
        return await StorageService.isFavorite(productId);
      }

      // Try Firebase first
      try {
        final doc = await _firestore
            .collection(FirebaseCollectionName.favorites)
            .doc('${currentUser.uid}_$productId')
            .get();
        
        return doc.exists;
      } catch (firebaseError) {
        _logger.log('Firebase error, checking local storage: $firebaseError');
        // Fallback to local storage
        return await StorageService.isFavorite(productId);
      }
    } catch (e) {
      _logger.log('Error checking if favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String productId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(productId);
      
      if (isCurrentlyFavorite) {
        await removeFromFavorites(productId);
        return false;
      } else {
        await addToFavorites(productId);
        return true;
      }
    } catch (e) {
      _logger.log('Error toggling favorite: $e');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      _logger.log('Error getting favorites count: $e');
      return 0;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Clear from Firebase
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.favorites)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear from local storage
      final localFavorites = await StorageService.getFavorites();
      for (final favorite in localFavorites) {
        await StorageService.removeFromFavorites(favorite);
      }

      _logger.log('Favorites cleared successfully');
    } catch (e) {
      _logger.log('Error clearing favorites: $e');
      throw Exception('Failed to clear favorites: $e');
    }
  }

  /// Sync local favorites with Firebase
  Future<void> syncLocalFavoritesWithFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get local favorites
      final localFavorites = await StorageService.getFavorites();
      
      // Get Firebase favorites
      final firebaseFavorites = await getFavoritesFromFirebase();
      
      // Create a set of Firebase favorites for quick lookup
      final firebaseFavoritesSet = firebaseFavorites.toSet();
      
      // Add local favorites that don't exist in Firebase
      for (final favorite in localFavorites) {
        if (!firebaseFavoritesSet.contains(favorite)) {
          await _addToFirestoreFavorites(favorite, currentUser.uid);
        }
      }
      
      _logger.log('Synced ${localFavorites.length} local favorites with Firebase');
    } catch (e) {
      _logger.log('Error syncing local favorites with Firebase: $e');
      throw Exception('Failed to sync favorites: $e');
    }
  }

  /// Send like notification to product owner
  Future<void> _sendLikeNotification(String productId, String likerId) async {
    try {
      print('DEBUG: _sendLikeNotification called for product: $productId, liker: $likerId');
      
      // Get product details
      final productService = ProductService();
      final products = await productService.getProductsFromFirebase();
      final product = products.firstWhere((p) => p.id == productId);
      
      print('DEBUG: Product found: ${product.name}, createdBy: ${product.createdBy}');
      
      // Get liker details
      final likerDoc = await _firestore
          .collection(FirebaseCollectionName.users)
          .doc(likerId)
          .get();
      
      print('DEBUG: Liker document exists: ${likerDoc.exists}');
      
      if (!likerDoc.exists) {
        print('DEBUG: Liker document not found, creating basic user info');
        final likerName = 'Someone';
        
        // Send notification even without user document
        final notificationService = NotificationService();
        await notificationService.sendLikeNotification(
          productId: productId,
          productName: product.name,
          likerName: likerName,
          productOwnerId: product.createdBy,
        );
        return;
      }
      
      final likerData = likerDoc.data()!;
      final likerName = likerData['displayName'] ?? likerData['email'] ?? 'Someone';
      
      print('DEBUG: Liker name: $likerName');
      print('DEBUG: About to call NotificationService.sendLikeNotification');
      
      // Send notification
      final notificationService = NotificationService();
      await notificationService.sendLikeNotification(
        productId: productId,
        productName: product.name,
        likerName: likerName,
        productOwnerId: product.createdBy,
      );
      
      print('DEBUG: NotificationService.sendLikeNotification completed');
      
      _logger.log('Like notification sent for product: $productId');
    } catch (e) {
      _logger.log('Error sending like notification: $e');
      // Don't throw error to avoid breaking the favorite functionality
    }
  }
}

