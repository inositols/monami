import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/utils/logger.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:monami/src/data/remote/product_service.dart';

/// Service to handle product ratings and reviews with Firebase
class RatingService {
  final _logger = Logger(RatingService);
  final _firestore = FirebaseFirestore.instance;

  /// Submit a rating and review for a product
  Future<bool> submitRating({
    required String productId,
    required double rating,
    String? review,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create rating document
      final ratingData = {
        'userId': currentUser.uid,
        'productId': productId,
        'rating': rating,
        'review': review,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Save rating to Firebase
      await _firestore
          .collection(FirebaseCollectionName.reviews)
          .add(ratingData);

      // Update product rating statistics
      await _updateProductRatingStats(productId);

      // Send notification to product owner
      await _sendReviewNotification(productId, currentUser.uid, rating);

      _logger.log('Rating submitted successfully for product: $productId');
      print('DEBUG: Review notification trigger called for product: $productId');
      return true;
    } catch (e) {
      _logger.log('Error submitting rating: $e');
      return false;
    }
  }

  /// Update product rating statistics
  Future<void> _updateProductRatingStats(String productId) async {
    try {
      // Get all ratings for this product
      final ratingsSnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .where('productId', isEqualTo: productId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      // Calculate average rating and total count
      double totalRating = 0.0;
      int totalCount = 0;

      for (final doc in ratingsSnapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] as num).toDouble();
        totalCount++;
      }

      final averageRating = totalRating / totalCount;

      // Update product with new rating statistics
      await _firestore
          .collection(FirebaseCollectionName.products)
          .doc(productId)
          .update({
        'rating': averageRating,
        'reviewCount': totalCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.log('Product rating stats updated: $productId - Rating: $averageRating, Count: $totalCount');
    } catch (e) {
      _logger.log('Error updating product rating stats: $e');
    }
  }

  /// Get ratings for a specific product
  Future<List<Map<String, dynamic>>> getProductRatings(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _logger.log('Retrieved ${ratings.length} ratings for product: $productId');
      return ratings;
    } catch (e) {
      _logger.log('Error getting product ratings: $e');
      return [];
    }
  }

  /// Get user's rating for a specific product
  Future<Map<String, dynamic>?> getUserRating(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      _logger.log('Error getting user rating: $e');
      return null;
    }
  }

  /// Update existing rating
  Future<bool> updateRating({
    required String ratingId,
    required double rating,
    String? review,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the rating document to verify ownership
      final ratingDoc = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .doc(ratingId)
          .get();

      if (!ratingDoc.exists) {
        throw Exception('Rating not found');
      }

      final ratingData = ratingDoc.data()!;
      if (ratingData['userId'] != currentUser.uid) {
        throw Exception('Not authorized to update this rating');
      }

      // Update rating
      await _firestore
          .collection(FirebaseCollectionName.reviews)
          .doc(ratingId)
          .update({
        'rating': rating,
        'review': review,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update product rating statistics
      await _updateProductRatingStats(ratingData['productId']);

      _logger.log('Rating updated successfully: $ratingId');
      return true;
    } catch (e) {
      _logger.log('Error updating rating: $e');
      return false;
    }
  }

  /// Delete rating
  Future<bool> deleteRating(String ratingId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the rating document to verify ownership and get productId
      final ratingDoc = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .doc(ratingId)
          .get();

      if (!ratingDoc.exists) {
        throw Exception('Rating not found');
      }

      final ratingData = ratingDoc.data()!;
      if (ratingData['userId'] != currentUser.uid) {
        throw Exception('Not authorized to delete this rating');
      }

      final productId = ratingData['productId'];

      // Delete rating
      await _firestore
          .collection(FirebaseCollectionName.reviews)
          .doc(ratingId)
          .delete();

      // Update product rating statistics
      await _updateProductRatingStats(productId);

      _logger.log('Rating deleted successfully: $ratingId');
      return true;
    } catch (e) {
      _logger.log('Error deleting rating: $e');
      return false;
    }
  }

  /// Get user's all ratings
  Future<List<Map<String, dynamic>>> getUserRatings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _logger.log('Retrieved ${ratings.length} user ratings');
      return ratings;
    } catch (e) {
      _logger.log('Error getting user ratings: $e');
      return [];
    }
  }

  /// Get rating statistics for a product
  Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .where('productId', isEqualTo: productId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalRatings': 0,
          'ratingDistribution': <int, int>{},
        };
      }

      double totalRating = 0.0;
      int totalCount = 0;
      final ratingDistribution = <int, int>{};

      for (final doc in ratingsSnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] as num).toDouble();
        totalRating += rating;
        totalCount++;

        final ratingFloor = rating.floor();
        ratingDistribution[ratingFloor] = (ratingDistribution[ratingFloor] ?? 0) + 1;
      }

      final averageRating = totalRating / totalCount;

      return {
        'averageRating': averageRating,
        'totalRatings': totalCount,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      _logger.log('Error getting product rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'ratingDistribution': <int, int>{},
      };
    }
  }

  /// Check if user has rated a product
  Future<bool> hasUserRated(String productId) async {
    try {
      final rating = await getUserRating(productId);
      return rating != null;
    } catch (e) {
      _logger.log('Error checking if user has rated: $e');
      return false;
    }
  }

  /// Get recent ratings across all products
  Future<List<Map<String, dynamic>>> getRecentRatings({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.reviews)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final ratings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _logger.log('Retrieved ${ratings.length} recent ratings');
      return ratings;
    } catch (e) {
      _logger.log('Error getting recent ratings: $e');
      return [];
    }
  }

  /// Send review notification to product owner
  Future<void> _sendReviewNotification(String productId, String reviewerId, double rating) async {
    try {
      // Get product details
      final productService = ProductService();
      final products = await productService.getProductsFromFirebase();
      final product = products.firstWhere((p) => p.id == productId);
      
      // Get reviewer details
      final reviewerDoc = await _firestore
          .collection(FirebaseCollectionName.users)
          .doc(reviewerId)
          .get();
      
      if (!reviewerDoc.exists) return;
      
      final reviewerData = reviewerDoc.data()!;
      final reviewerName = reviewerData['displayName'] ?? reviewerData['email'] ?? 'Someone';
      
      // Send notification
      final notificationService = NotificationService();
      await notificationService.sendReviewNotification(
        productId: productId,
        productName: product.name,
        reviewerName: reviewerName,
        productOwnerId: product.createdBy,
        rating: rating,
      );
      
      _logger.log('Review notification sent for product: $productId');
    } catch (e) {
      _logger.log('Error sending review notification: $e');
      // Don't throw error to avoid breaking the rating functionality
    }
  }
}

