import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:monami/app.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/src/presentation/views/product/demo_samples.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/services/storage_service.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:device_preview/device_preview.dart' show DevicePreview;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupLocator();
  await StorageService.init();
  
  // Initialize Firebase Messaging
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  await initializeSampleData();

  runApp(
    DevicePreview(builder: (context) => const App()),
  );
}
