import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SmartParkingSenseApp());
}

class SmartParkingSenseApp extends StatelessWidget {
  const SmartParkingSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartParkingSense',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF153E75),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFEFF4FA),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
