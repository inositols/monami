import 'package:flutter/material.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';
import 'package:monami/src/utils/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monami',
      // theme: lightTheme.copyWith(
      //   textTheme: GoogleFonts.notoSansTextTheme(lightTheme.textTheme),
      // ),
      scaffoldMessengerKey: locator<SnackbarHandler>().key,
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
      initialRoute: Routes.splashScreenViewRoute,
      builder: (_, child) => ProviderScope(child: child!),
    );
  }
}
