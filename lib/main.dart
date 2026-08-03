import 'package:flutter/material.dart';
import 'database.dart';
import 'current_device.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore saved device
  await CurrentDevice.load();

  try {
    await Database.connect();
    debugPrint("Database connected");
  } catch (e) {
    debugPrint("Database connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
  }
}
