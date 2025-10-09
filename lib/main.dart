import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:monami/app.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/services/storage_service.dart';
import 'package:monami/src/models/product_model.dart';

import 'package:device_preview/device_preview.dart' show DevicePreview;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupLocator();
  await StorageService.init();
  await _initializeSampleData();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const App(),
    ),
  );
}

Future<void> _initializeSampleData() async {
  final existingProducts = await StorageService.getProducts();
  if (existingProducts.isNotEmpty) {
    return;
  }

  // Add sample products
  final sampleProducts = [
    Product(
      id: '1',
      name: 'Premium Wireless Headphones',
      description:
          'High-quality wireless headphones with noise cancellation and premium sound quality.',
      price: 299.99,
      category: 'Electronics',
      images: [
        'assets/images/headphone_6.png',
        'assets/images/headphone_7.png'
      ],
      colors: ['Black', 'White', 'Silver'],
      sizes: ['Standard'],
      stockQuantity: 50,
      rating: 4.8,
      reviewCount: 127,
      createdAt: DateTime.now(),
      brand: 'AudioTech',
    ),
    Product(
      id: '2',
      name: 'Designer Handbag',
      description:
          'Elegant designer handbag perfect for both casual and formal occasions.',
      price: 189.50,
      category: 'Fashion',
      images: ['assets/images/bag_1.png', 'assets/images/bag_2.png'],
      colors: ['Brown', 'Black', 'Beige'],
      sizes: ['Small', 'Medium', 'Large'],
      stockQuantity: 25,
      rating: 4.9,
      reviewCount: 89,
      createdAt: DateTime.now(),
      brand: 'LuxeBags',
    ),
    Product(
      id: '3',
      name: 'Elegant Ring Collection',
      description:
          'Beautiful handcrafted rings made with premium materials and attention to detail.',
      price: 89.99,
      category: 'Fashion',
      images: ['assets/images/ring_2.png', 'assets/images/ring_4.png'],
      colors: ['Gold', 'Silver', 'Rose Gold'],
      sizes: ['S', 'M', 'L'],
      stockQuantity: 15,
      rating: 4.7,
      reviewCount: 34,
      createdAt: DateTime.now(),
      brand: 'Jewelry Co',
    ),
    Product(
      id: '4',
      name: 'Stylish Baseball Cap',
      description:
          'Comfortable and stylish baseball cap perfect for outdoor activities.',
      price: 45.00,
      category: 'Fashion',
      images: ['assets/images/cap_1.png', 'assets/images/cap_3.png'],
      colors: ['Blue', 'Black', 'Red', 'White'],
      sizes: ['S', 'M', 'L', 'XL'],
      stockQuantity: 75,
      rating: 4.6,
      reviewCount: 156,
      createdAt: DateTime.now(),
      brand: 'CapStyle',
    ),
    Product(
      id: '5',
      name: 'Gaming Headphones',
      description:
          'Professional gaming headphones with surround sound and comfortable design.',
      price: 159.99,
      category: 'Electronics',
      images: ['assets/images/headphone_8.png'],
      colors: ['Black', 'Red'],
      sizes: ['Standard'],
      stockQuantity: 30,
      rating: 4.5,
      reviewCount: 78,
      createdAt: DateTime.now(),
      brand: 'GameSound',
    ),
  ];

  // Save each sample product
  for (final product in sampleProducts) {
    await StorageService.saveProduct(product.toJson());
  }
}
