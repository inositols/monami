import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:monami/app.dart';
import 'package:monami/firebase_options.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/data/remote/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(
    App(),
  );
}
