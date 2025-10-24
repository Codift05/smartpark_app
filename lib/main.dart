import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snap.data;
          if (user != null) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
