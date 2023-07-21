import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/state/auth/providers/auth_state_provider.dart';
import 'package:monami/views/bottomnavigation/bottom_navigation_screen.dart';
import 'package:monami/views/login/login_view.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider1);
    return MaterialApp(
      title: 'Monami',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: authState.when(
        data: (user) {
          if (user != null) return const BottomNavigation();
          return const LoginView();
        },
        error: (error, stackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
