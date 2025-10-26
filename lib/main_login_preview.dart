import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const SmartParkingPreviewApp());
}

class SmartParkingPreviewApp extends StatelessWidget {
  const SmartParkingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartParkingSense Preview',
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFF00897B),
          secondary: const Color(0xFF26A69A),
        ),
      ),
      home: const LoginPage(),
    );
  }
}