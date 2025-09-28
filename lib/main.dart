// Temporarily disabled Firebase for web testing
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;

import 'package:monami/app.dart';
// import 'package:monami/firebase_options.dart';

import 'package:monami/src/utils/router/locator.dart';

import 'package:device_preview/device_preview.dart' show DevicePreview;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporarily disabled Firebase initialization for web testing
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await setupLocator();
  runApp(
    DevicePreview(enabled: true, builder: (context) => const App()),
  );
}
