import 'package:flutter/material.dart';
import 'checkout_view.dart';

class CheckoutDemo extends StatelessWidget {
  const CheckoutDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final List<CheckoutItem> demoItems = [
      CheckoutItem(
        id: 1,
        name: "Premium Wireless Headphones",
        price: 299.99,
        quantity: 1,
        image: "assets/images/headphone_6.png",
      ),
      CheckoutItem(
        id: 2,
        name: "Designer Handbag",
        price: 189.50,
        quantity: 2,
        image: "assets/images/bag_1.png",
      ),
    ];

    const double subtotal = 679.98;
    const double shipping = 0.0; // Free shipping
    const double tax = 54.40;

    return CheckoutView(
      items: demoItems,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
    );
  }
}
