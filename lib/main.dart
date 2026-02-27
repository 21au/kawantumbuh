import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/main_wrapper.dart';
import 'package:kawantumbuh/screens/splash_screen.dart';

void main() {
  runApp(const KawanTumbuhApp());
}

class KawanTumbuhApp extends StatelessWidget {
  const KawanTumbuhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KawanTumbuh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainWrapper(), // Mulai dari sini
    );
  }
}