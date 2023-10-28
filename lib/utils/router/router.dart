import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monami/views/bottomnavigation/bottom_navigation_screen.dart';
import 'package:monami/views/login/login_view.dart';
import 'route_name.dart';

Route<Object?>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case home:
      return _getPageRoute(
        const BottomNavigation(),
      );
    case loginRoute:
      return _getPageRoute(
        const LoginView(),
      );

    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

CupertinoPageRoute<Object> _getPageRoute(
  Widget child, [
  String? routeName,
  dynamic args,
]) =>
    CupertinoPageRoute(
      builder: (context) => child,
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
    );
