import 'package:flutter/material.dart';
import 'package:monami/src/features/cart/view/cart_view.dart';

import 'package:monami/views/home_view.dart';
import 'package:monami/views/profile/profile_view.dart';

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
  NavigatorItem("Favourite", "assets/icons/favourite_icon.svg", 3, Container()),
  NavigatorItem(
      "Account", "assets/icons/account_icon.svg", 4, const ProfileView()),
];
