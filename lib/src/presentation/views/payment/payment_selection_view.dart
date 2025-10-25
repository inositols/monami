// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:monami/src/data/remote/payment_service.dart';
// import 'package:monami/src/models/product_model.dart';
// import 'package:monami/src/handlers/handlers.dart';
// import 'package:monami/src/data/local/local_cache.dart';
// import 'package:monami/src/data/remote/auth_service.dart';
// import 'package:monami/src/utils/router/locator.dart';
// import 'package:monami/src/utils/router/route_name.dart';

// class PaymentSelectionView extends StatefulWidget {
//   final List<CartItem> cartItems;
//   final double totalAmount;

//   const PaymentSelectionView({
//     Key? key,
//     required this.cartItems,
//     required this.totalAmount,
//   }) : super(key: key);

//   @override
//   State<PaymentSelectionView> createState() => _PaymentSelectionViewState();
// }

// class _PaymentSelectionViewState extends State<PaymentSelectionView> {
//   // final PaymentService _paymentService = PaymentService();
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _expiryController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
//   final TextEditingController _cardNameController = TextEditingController();
  
//   // Centralized services
//   late final NavigationService _navigationService = locator<NavigationService>();
//   late final SnackbarHandler _snackbarHandler = locator<SnackbarHandler>();
//   late final LocalCache _localCache = locator<LocalCache>();
//   late final AuthService _authService = locator<AuthService>();
  
//   String _selectedPaymentMethod = 'paypal';
//   bool _isProcessing = false;

//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     _cardNameController.dispose();
//     super.dispose();
//   }

//   Future<void> _processPayment() async {
//     if (_isProcessing) return;

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
//       final orderDetails = {
//         'items': widget.cartItems.map((item) => {
//           'productId': item.productId,
//           'productName': item.productName,
//           'quantity': item.quantity,
//           'price': item.price,
//         }).toList(),
//         'totalAmount': widget.totalAmount,
//         'currency': 'USD',
//       };

//       PaymentResult result;

//       switch (_selectedPaymentMethod) {
//         case 'paypal':
//           result = await _paymentService.processPayPalPayment(
//             orderId: orderId,
//             amount: widget.totalAmount,
//             currency: 'USD',
//             orderDetails: orderDetails,
//           );
//           break;
//         case 'google_pay':
//           result = await _paymentService.processGooglePayPayment(
//             orderId: orderId,
//             amount: widget.totalAmount,
//             currency: 'USD',
//             orderDetails: orderDetails,
//           );
//           break;
//         case 'credit_card':
//           if (!_validateCreditCard()) {
//             throw Exception('Please fill in all credit card details');
//           }
//           result = await _paymentService.processCreditCardPayment(
//             orderId: orderId,
//             amount: widget.totalAmount,
//             currency: 'USD',
//             orderDetails: orderDetails,
//             cardDetails: {
//               'last4': _cardNumberController.text.substring(
//                 _cardNumberController.text.length - 4,
//               ),
//               'brand': 'Visa', // Simplified
//             },
//           );
//           break;
//         default:
//           throw Exception('Invalid payment method');
//       }

//       if (result.success) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Payment successful! Order ID: $orderId',
//                 style: GoogleFonts.inter(fontWeight: FontWeight.w500),
//               ),
//               backgroundColor: Colors.green.shade400,
//             ),
//           );
          
//           _navigationService.pushReplacementNamed(Routes.orderSuccessRoute, arguments: {
//             'orderId': orderId,
//             'transactionId': result.transactionId,
//           });
//         }
//       } else {
//         throw Exception(result.message);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Payment failed: ${e.toString()}',
//               style: GoogleFonts.inter(fontWeight: FontWeight.w500),
//             ),
//             backgroundColor: Colors.red.shade400,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }

//   bool _validateCreditCard() {
//     return _cardNumberController.text.isNotEmpty &&
//            _expiryController.text.isNotEmpty &&
//            _cvvController.text.isNotEmpty &&
//            _cardNameController.text.isNotEmpty;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Payment',
//           style: GoogleFonts.inter(
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//             color: const Color(0xFF2D3748),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Order Summary
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Order Summary',
//                           style: GoogleFonts.inter(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: const Color(0xFF2D3748),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ...widget.cartItems.map((item) => Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 '${item.productName} x${item.quantity}',
//                                 style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   color: const Color(0xFF2D3748),
//                                 ),
//                               ),
//                               Text(
//                                 '\$${(item.totalPrice).toStringAsFixed(2)}',
//                                 style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: const Color(0xFF2D3748),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )),
//                         const Divider(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Total',
//                               style: GoogleFonts.inter(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w700,
//                                 color: const Color(0xFF2D3748),
//                               ),
//                             ),
//                             Text(
//                               '\$${widget.totalAmount.toStringAsFixed(2)}',
//                               style: GoogleFonts.inter(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w700,
//                                 color: const Color(0xFF667EEA),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Payment Methods
//                   Text(
//                     'Payment Method',
//                     style: GoogleFonts.inter(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF2D3748),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // PayPal
//                   _buildPaymentMethod(
//                     'paypal',
//                     'PayPal',
//                     'Pay with your PayPal account',
//                     Icons.payment,
//                     Colors.blue,
//                   ),

//                   const SizedBox(height: 12),

//                   // Google Pay
//                   _buildPaymentMethod(
//                     'google_pay',
//                     'Google Pay',
//                     'Pay with Google Pay',
//                     Icons.payment,
//                     Colors.green,
//                   ),

//                   const SizedBox(height: 12),

//                   // Credit Card
//                   _buildPaymentMethod(
//                     'credit_card',
//                     'Credit Card',
//                     'Pay with credit or debit card',
//                     Icons.credit_card,
//                     Colors.purple,
//                   ),

//                   // Credit Card Form
//                   if (_selectedPaymentMethod == 'credit_card') ...[
//                     const SizedBox(height: 20),
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Card Details',
//                             style: GoogleFonts.inter(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF2D3748),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextField(
//                             controller: _cardNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Cardholder Name',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextField(
//                             controller: _cardNumberController,
//                             decoration: InputDecoration(
//                               labelText: 'Card Number',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             keyboardType: TextInputType.number,
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: _expiryController,
//                                   decoration: InputDecoration(
//                                     labelText: 'MM/YY',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: TextField(
//                                   controller: _cvvController,
//                                   decoration: InputDecoration(
//                                     labelText: 'CVV',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   keyboardType: TextInputType.number,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),

//           // Pay Button
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isProcessing ? null : _processPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF667EEA),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _isProcessing
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : Text(
//                         'Pay \$${widget.totalAmount.toStringAsFixed(2)}',
//                         style: GoogleFonts.inter(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentMethod(
//     String value,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//   ) {
//     final isSelected = _selectedPaymentMethod == value;
    
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedPaymentMethod = value;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF667EEA) : Colors.grey.shade200,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: const Color(0xFF667EEA).withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.inter(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF2D3748),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               const Icon(
//                 Icons.check_circle,
//                 color: Color(0xFF667EEA),
//                 size: 24,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

