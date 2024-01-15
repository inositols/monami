import 'package:flutter/material.dart';
import 'package:monami/src/shared/base_scaffold.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
        backgroundColor: Colors.white,
        builder: (size) {
          return Column(
            children: [],
          );
        });
  }
}
