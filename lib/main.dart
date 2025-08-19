import 'package:flutter/material.dart';
import 'package:SealApp/app_classes/Splash_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added key for better performance

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      home: SplashScreen(),
    );
  }
}
