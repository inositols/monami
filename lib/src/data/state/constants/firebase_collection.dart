import 'package:flutter/foundation.dart' show immutable;

// a fle that contains the various firebase collections
@immutable
class FirebaseCollectionName {
  static const users = "users";
  static const thumbnail = "thumbnail";
  static const products = "products";
  static const reviews = "reviews";
  static const likes = "likes";
  static const followers = "followers";
  static const following = "following";
  static const chats = "chats";
  static const carts = "carts";
  static const orders = "orders";

  const FirebaseCollectionName._();
}
