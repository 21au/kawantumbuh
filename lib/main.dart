import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Ini jembatan untuk memanggil file alarm yang di atas tadi
import 'notification_helper.dart'; 

void main() async {
  // Wajib tambahkan ini agar Flutter siap menjalankan proses sebelum aplikasi muncul
  WidgetsFlutterBinding.ensureInitialized();

  // Menyalakan mesin notifikasi (Alarm)
  await NotificationHelper.init();

  // INI DIA SUPABASE-NYA YANG HILANG! 🥰
  await Supabase.initialize(
    url: 'https://xejvpubnotnpevkbpwoh.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlanZwdWJub3RucGV2a2Jwd29oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2ODcxMjIsImV4cCI6MjA4ODI2MzEyMn0.BF2Rqgc4SxKFeTDKY7urdtJHy1Xa6Wvi5Tl9DBjl-uQ',
  );

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
      home: const SplashScreen(), // Mulai dari sini
    );
  }
}