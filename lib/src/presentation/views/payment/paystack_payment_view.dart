import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/data/remote/paystack_service.dart';
import 'package:monami/src/data/remote/orders_service.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:monami/src/data/remote/product_service.dart';
import 'package:monami/src/models/product_model.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaystackPaymentView extends StatefulWidget {
  final Orders order;
  final List<CartItem> items;

  const PaystackPaymentView({
    Key? key,
    required this.order,
    required this.items,
  }) : super(key: key);

  @override
  State<PaystackPaymentView> createState() => _PaystackPaymentViewState();
}

class _PaystackPaymentViewState extends State<PaystackPaymentView> {
  final PaystackPlusService _paystackService = PaystackPlusService();
  final OrdersService _ordersService = OrdersService();
  final NotificationService _notificationService = NotificationService();
  final _navigationService = locator<NavigationService>();
  final _snackbarHandler = locator<SnackbarHandler>();

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _customerEmail;
  String? _customerName;

  @override
  void initState() {
    super.initState();
    // _initializePaystack();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _customerEmail = currentUser.email ?? '';
          _customerName = currentUser.displayName ?? 'Customer';
        });
      }
    } catch (e) {
      print('Error loading customer info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pay with Paystack',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF1A202C),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A202C)),
          onPressed: () {
            _navigationService.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary
            _buildPaymentSummary(),
            const SizedBox(height: 24),

            // Customer Information
            _buildCustomerInfo(),
            const SizedBox(height: 24),

            // Payment Button
            _buildPaymentButton(),
            const SizedBox(height: 20),

            // Payment Methods Info
            _buildPaymentMethodsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.items.map((item) => _buildOrderItem(item)),
          const Divider(),
          _buildTotalRow('Subtotal', widget.order.subtotal),
          _buildTotalRow('Shipping', widget.order.shipping),
          _buildTotalRow('Tax', widget.order.tax),
          const Divider(),
          _buildTotalRow('Total', widget.order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color:
                  isTotal ? const Color(0xFF1A202C) : const Color(0xFF4A5568),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color:
                  isTotal ? const Color(0xFF1A202C) : const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            // initialValue: _customerEmail,
            onChanged: (value) {
              setState(() {
                _customerEmail = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            // initialValue: _customerName,
            onChanged: (value) {
              setState(() {
                _customerName = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Pay \$${widget.order.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildPaymentMethodsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: const Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Secure Payment',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment is secured by Paystack. We accept all major cards and bank transfers.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_customerEmail == null || _customerEmail!.isEmpty) {
      _snackbarHandler.showErrorSnackbar('Please enter your email address');
      return;
    }

    if (_customerName == null || _customerName!.isEmpty) {
      _snackbarHandler.showErrorSnackbar('Please enter your full name');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _paystackService.startPayment(
        amount: widget.order.total,
        email: _customerEmail!,
        context: context,
      );

      // if (response.isSuccessful) {
      //   // Verify payment
      //   final isVerified =
      //       await _paystackService.verifyPayment(response.reference);

      //   if (isVerified) {
      //     // Update order status
      //     final updatedOrder = widget.order.copyWith(
      //       status: 'completed',
      //       paymentMethod: 'Paystack',
      //       paymentId: response.reference,
      //       completedAt: DateTime.now(),
      //     );

      //     // Save updated order
      //     await _ordersService.updateOrder(updatedOrder);

      //     // Send notifications to product owners
      //     await _sendPurchaseNotifications(updatedOrder);

      //     // Show success message
      //     _snackbarHandler.showSnackbar('Payment completed successfully!');

      //     // Navigate back to home
      //     _navigationService.pushNamedAndRemoveUntil(
      //       '/home', // Replace with your home route
      //       '/',
      //     );
      //   } else {
      //     _snackbarHandler.showErrorSnackbar('Payment verification failed');
      //   }
      // } else {
      //   _snackbarHandler
      //       .showErrorSnackbar('Payment failed: ${response.message}');
      // }
    } catch (e) {
      _snackbarHandler.showErrorSnackbar('Error processing payment: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendPurchaseNotifications(Orders order) async {
    try {
      // Get current user for buyer name
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final buyerName =
          currentUser.displayName ?? currentUser.email ?? 'Someone';

      // Get product details to find product owners
      final productService = ProductService();
      final products = await productService.getProductsFromFirebase();

      // Group items by product owner
      final Map<String, List<CartItem>> ownerItems = {};

      for (final item in widget.items) {
        final product = products.firstWhere((p) => p.id == item.productId);
        final ownerId = product.createdBy;

        if (!ownerItems.containsKey(ownerId)) {
          ownerItems[ownerId] = [];
        }
        ownerItems[ownerId]!.add(item);
      }

      // Send notification for each product owner
      for (final entry in ownerItems.entries) {
        final ownerId = entry.key;
        final items = entry.value;

        // Calculate total for this owner
        double totalAmount = 0;
        int totalQuantity = 0;
        String productNames = '';

        for (final item in items) {
          totalAmount += item.price * item.quantity;
          totalQuantity += item.quantity;
          if (productNames.isNotEmpty) productNames += ', ';
          productNames += item.productName;
        }

        // Send notification
        await _notificationService.sendPurchaseNotification(
          productId: items.first.productId,
          productName: productNames,
          buyerName: buyerName,
          productOwnerId: ownerId,
          quantity: totalQuantity,
          totalAmount: totalAmount,
        );
      }
    } catch (e) {
      print('Error sending purchase notifications: $e');
    }
  }
}
