import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monami',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: const HomeView(),
    );
  }
}
