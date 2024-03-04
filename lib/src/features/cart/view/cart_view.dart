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
        // appBar: ,
        builder: (size) {
          return Column(
              children: listOfCart.map((item) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Text(item.id.toString()),
                    title: Text(item.itemName),
                    subtitle: Text(item.itemPrice.toString()),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove),
                          ),
                          const Text("0"),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }).toList());
        });
  }
}

class CartModel {
  final int id;
  final String itemName;
  final int itemPrice;
  const CartModel({
    required this.id,
    required this.itemName,
    required this.itemPrice,
  });
}

const List<CartModel> listOfCart = [
  CartModel(id: 1, itemName: "Shoe", itemPrice: 100),
  CartModel(id: 2, itemName: "Bag", itemPrice: 10),
  CartModel(id: 3, itemName: "Gown", itemPrice: 50),
];
