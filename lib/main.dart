import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/state/auth/providers/auth_state_provider.dart';
import 'package:monami/views/home_view.dart';
import 'package:monami/views/login/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'Monami',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: authState.when(
        data: (user) {
          if (user != null) return const HomeView();
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
