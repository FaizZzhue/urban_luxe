import 'package:flutter/material.dart';
import 'package:urban_luxe/screens/start_screens.dart';
import 'package:urban_luxe/screens/sign_in_screens.dart';
import 'package:urban_luxe/screens/sign_up_screens.dart';
import 'package:urban_luxe/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Luxe',
      theme: ThemeData(
        primaryColor: const Color(0xFF008A4E),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        useMaterial3: false,
      ),

      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartScreens(),
        '/signin': (context) => const SignInScreens(),
        '/signup': (context) => const SignUpScreens(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}