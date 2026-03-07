import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/login_screen.dart' as login;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color highlightPink = const Color(0xFFEBA9A9);

  double _opacity = 0.0;
  double _scale = 0.5; 

  @override
  void initState() {
    super.initState();
    
    // Memulai animasi setelah delay kecil
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Pindah ke halaman Login setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Transisi fade yang mulus
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800), 
            pageBuilder: (_, __, ___) => const login.LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👇 BACKGROUND DIUBAH JADI TERANG (SOFT PINK)
      backgroundColor: softPink, 
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gambar logo
                Image.asset(
                  'assets/images/logo.png', 
                  width: 210, 
                  height: 210,
                  fit: BoxFit.contain,
                ),
                
                const SizedBox(height: 20),
                Text(
                  "KawanTumbuh",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    // 👇 TEKS DIUBAH JADI GELAP (NAVY DARK)
                    color: navyDark, 
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tumbuh Bersama, Lebih Bermakna",
                  style: TextStyle(
                    fontSize: 17,
                    // 👇 TEKS SUBTITLE JUGA NAVY DARK (Diberi sedikit opacity biar lebih estetik)
                    color: navyDark.withOpacity(0.8), 
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}