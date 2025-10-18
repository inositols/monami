import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle payment processing with PayPal and Google Pay
class PaymentService {
  final _logger = Logger(PaymentService);
  final _firestore = FirebaseFirestore.instance;

  /// Process payment with PayPal
  Future<PaymentResult> processPayPalPayment({
    required String orderId,
    required double amount,
    required String currency,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _logger.log('Processing PayPal payment for order: $orderId');

      // Simulate PayPal payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create payment record in Firebase
      final paymentData = {
        'orderId': orderId,
        'userId': currentUser.uid,
        'amount': amount,
        'currency': currency,
        'paymentMethod': 'PayPal',
        'status': 'completed',
        'transactionId': 'PP_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'orderDetails': orderDetails,
      };

      await _firestore.collection('payments').doc(orderId).set(paymentData);

      // Update order status
      await _updateOrderStatus(orderId, 'paid');

      _logger.log('PayPal payment completed successfully');
      return PaymentResult(
        success: true,
        transactionId: paymentData['transactionId'] as String?,
        message: 'Payment completed successfully',
      );
    } catch (e) {
      _logger.log('PayPal payment failed: $e');
      return PaymentResult(
        success: false,
        transactionId: null,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Process payment with Google Pay
  Future<PaymentResult> processGooglePayPayment({
    required String orderId,
    required double amount,
    required String currency,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _logger.log('Processing Google Pay payment for order: $orderId');

      // Simulate Google Pay payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create payment record in Firebase
      final paymentData = {
        'orderId': orderId,
        'userId': currentUser.uid,
        'amount': amount,
        'currency': currency,
        'paymentMethod': 'Google Pay',
        'status': 'completed',
        'transactionId': 'GP_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'orderDetails': orderDetails,
      };

      await _firestore.collection('payments').doc(orderId).set(paymentData);

      // Update order status
      await _updateOrderStatus(orderId, 'paid');

      _logger.log('Google Pay payment completed successfully');
      return PaymentResult(
        success: true,
        transactionId: paymentData['transactionId'] as String,
        message: 'Payment completed successfully',
      );
    } catch (e) {
      _logger.log('Google Pay payment failed: $e');
      return PaymentResult(
        success: false,
        transactionId: null,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Process credit card payment
  Future<PaymentResult> processCreditCardPayment({
    required String orderId,
    required double amount,
    required String currency,
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> cardDetails,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _logger.log('Processing credit card payment for order: $orderId');

      // Simulate credit card payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Create payment record in Firebase
      final paymentData = {
        'orderId': orderId,
        'userId': currentUser.uid,
        'amount': amount,
        'currency': currency,
        'paymentMethod': 'Credit Card',
        'status': 'completed',
        'transactionId': 'CC_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'orderDetails': orderDetails,
        'cardDetails': {
          'last4': cardDetails['last4'],
          'brand': cardDetails['brand'],
        },
      };

      await _firestore.collection('payments').doc(orderId).set(paymentData);

      // Update order status
      await _updateOrderStatus(orderId, 'paid');

      _logger.log('Credit card payment completed successfully');
      return PaymentResult(
        success: true,
        transactionId: paymentData['transactionId'] as String,
        message: 'Payment completed successfully',
      );
    } catch (e) {
      _logger.log('Credit card payment failed: $e');
      return PaymentResult(
        success: false,
        transactionId: null,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Update order status
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(FirebaseCollectionName.orders)
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.log('Error updating order status: $e');
    }
  }

  /// Get payment history for user
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final payments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _logger.log('Retrieved ${payments.length} payment records');
      return payments;
    } catch (e) {
      _logger.log('Error getting payment history: $e');
      return [];
    }
  }

  /// Get payment by order ID
  Future<Map<String, dynamic>?> getPaymentByOrderId(String orderId) async {
    try {
      final doc = await _firestore.collection('payments').doc(orderId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      _logger.log('Error getting payment by order ID: $e');
      return null;
    }
  }

  /// Refund payment
  Future<bool> refundPayment(String orderId, String reason) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get payment record
      final payment = await getPaymentByOrderId(orderId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 2));

      // Update payment status
      await _firestore.collection('payments').doc(orderId).update({
        'status': 'refunded',
        'refundReason': reason,
        'refundedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update order status
      await _updateOrderStatus(orderId, 'refunded');

      _logger.log('Payment refunded successfully: $orderId');
      return true;
    } catch (e) {
      _logger.log('Error refunding payment: $e');
      return false;
    }
  }
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
  });
}

