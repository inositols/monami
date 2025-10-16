import 'package:flutter/material.dart';
import 'package:monami/src/presentation/views/cart/cart_view.dart';
import 'package:monami/src/presentation/views/favorites/favorites_view.dart';
import 'package:monami/src/presentation/views/home/home_view.dart';
import 'package:monami/src/presentation/views/profile/profile_view.dart';

class NavigatorItem {
  final String label;
  final String iconPath;
  final int index;
  final Widget screen;

  NavigatorItem(this.label, this.iconPath, this.index, this.screen);
}

List<NavigatorItem> navigatorItems = [
  NavigatorItem("Shop", "assets/icons/shop_icon.svg", 0, const HomeView()),
  NavigatorItem("Cart", "assets/icons/cart_icon.svg", 2, const CartView()),
  NavigatorItem(
      "Favourite", "assets/icons/favourite_icon.svg", 3, const FavoritesView()),
  NavigatorItem(
      "Account", "assets/icons/account_icon.svg", 4, const ProfileView()),
];
