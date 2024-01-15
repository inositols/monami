import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/src/features/auth/providers/auth_state_provider.dart';
import 'package:monami/src/handlers/navigation_handler.dart';
import 'package:monami/src/handlers/snack_bar_handler.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/router.dart';
import 'package:monami/views/bottomnavigation/bottom_navigation_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:monami/views/onboarding/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationChangesProvider);
    return MaterialApp(
      title: 'Monami',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: locator<SnackbarHandler>().key,
      onGenerateRoute: generateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      home: authState.when(
        data: (user) =>
            user != null ? const BottomNavigation() : const OnboardingScreen(),
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
