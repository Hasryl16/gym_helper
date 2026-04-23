import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar — dark icons over our near-black bg
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase init — wrapped in try/catch so the app still boots without
  // a real google-services.json / GoogleService-Info.plist.
  // Run `flutterfire configure` to set up real credentials.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[GymHelper] Firebase init skipped: $e');
  }

  runApp(const GymHelperApp());
}
