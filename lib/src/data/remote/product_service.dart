import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/services/storage_service.dart';
import 'package:monami/src/utils/logger.dart';

/// Service to handle product operations with Firebase and local storage
class ProductService {
  final _logger = Logger(ProductService);
  final _firestore = FirebaseFirestore.instance;

  /// Create a new product and save to both Firebase and local storage
  Future<Product> createProduct(Product product) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Firebase Firestore
      await _uploadToFirestore(product, currentUser.uid);

      // Save to local storage
      await StorageService.saveProduct(product.toJson());

      _logger.log('Product created successfully: ${product.name}');
      return product;
    } catch (e) {
      _logger.log('Error creating product: $e');
      rethrow;
    }
  }

  /// Upload product to Firebase Firestore
  Future<void> _uploadToFirestore(Product product, String userId) async {
    try {
      await _firestore
          .collection(FirebaseCollectionName.products)
          .doc(product.id)
          .set({
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'images': product.images,
        'colors': product.colors,
        'sizes': product.sizes,
        'isAvailable': product.isAvailable,
        'stockQuantity': product.stockQuantity,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'createdAt': product.createdAt.toIso8601String(),
        'brand': product.brand,
        'specifications': product.specifications,
        'createdBy': userId, // Track who created the product
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.log('Product uploaded to Firestore successfully');
    } catch (e) {
      _logger.log('Error uploading to Firestore: $e');
      throw Exception('Failed to upload product to cloud: $e');
    }
  }

  /// Get all products from Firebase
  Future<List<Product>> getProductsFromFirebase() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.products)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson(data);
      }).toList();

      _logger.log('Retrieved ${products.length} products from Firebase');
      return products;
    } catch (e) {
      _logger.log('Error getting products from Firebase: $e');
      throw Exception('Failed to fetch products from cloud: $e');
    }
  }

  /// Get products by category from Firebase
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.products)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson(data);
      }).toList();

      _logger
          .log('Retrieved ${products.length} products for category: $category');
      return products;
    } catch (e) {
      _logger.log('Error getting products by category: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Get products created by current user
  Future<List<Product>> getUserProducts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.products)
          .where('createdBy', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson(data);
      }).toList();

      _logger.log('Retrieved ${products.length} user products');
      return products;
    } catch (e) {
      _logger.log('Error getting user products: $e');
      throw Exception('Failed to fetch user products: $e');
    }
  }

  /// Update product in Firebase
  Future<void> updateProduct(Product product) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update in Firebase
      await _firestore
          .collection(FirebaseCollectionName.products)
          .doc(product.id)
          .update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'images': product.images,
        'colors': product.colors,
        'sizes': product.sizes,
        'isAvailable': product.isAvailable,
        'stockQuantity': product.stockQuantity,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'brand': product.brand,
        'specifications': product.specifications,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update in local storage
      await StorageService.updateProduct(product.toJson());

      _logger.log('Product updated successfully: ${product.name}');
    } catch (e) {
      _logger.log('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete product from Firebase and local storage
  Future<void> deleteProduct(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Delete from Firebase
      await _firestore
          .collection(FirebaseCollectionName.products)
          .doc(productId)
          .delete();

      // Delete from local storage
      await StorageService.deleteProduct(productId);

      _logger.log('Product deleted successfully: $productId');
    } catch (e) {
      _logger.log('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Search products in Firebase
  Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot =
          await _firestore.collection(FirebaseCollectionName.products).get();

      final allProducts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson(data);
      }).toList();

      // Filter products by search query
      final filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()) ||
            (product.brand?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();

      _logger
          .log('Found ${filteredProducts.length} products for query: $query');
      return filteredProducts;
    } catch (e) {
      _logger.log('Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  /// Sync local products with Firebase
  Future<void> syncLocalProductsWithFirebase() async {
    try {
      // Get local products
      final localProducts = await StorageService.getProducts();

      // Get Firebase products
      final firebaseProducts = await getProductsFromFirebase();

      // Create a map of Firebase products by ID
      final firebaseProductsMap = {
        for (var product in firebaseProducts) product.id: product
      };

      // Update local storage with Firebase data
      for (final firebaseProduct in firebaseProducts) {
        await StorageService.updateProduct(firebaseProduct.toJson());
      }

      _logger
          .log('Synced ${firebaseProducts.length} products with local storage');
    } catch (e) {
      _logger.log('Error syncing products: $e');
      throw Exception('Failed to sync products: $e');
    }
  }


  /// Check if user owns a product
  Future<bool> isUserProduct(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }

      final doc = await _firestore
          .collection(FirebaseCollectionName.products)
          .doc(productId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      return data['createdBy'] == currentUser.uid;
    } catch (e) {
      _logger.log('Error checking if user owns product: $e');
      return false;
    }
  }
}
