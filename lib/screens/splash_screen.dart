import 'package:flutter/material.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'package:kawantumbuh/screens/login_screen.dart' as login;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    // Memulai animasi setelah delay kecil
    Future.delayed(const Duration(milliseconds: 500), () {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login.LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark, // Background gelap biar mewah
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
                // 👇 INI BAGIAN YANG DIUBAH: Menggunakan gambar logo
                Image.asset(
                  'assets/images/logo.png', // Pastikan nama file sesuai dengan yang kamu simpan
                  width: 210, // Ukuran logo bisa kamu ubah (misal: 100 atau 150)
                  height: 210,
                  fit: BoxFit.contain, // Memastikan gambar tidak terpotong
                ),
                // 👆 BATAS UBAHAN
                
                const SizedBox(height: 20),
                const Text(
                  "KawanTumbuh",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightPink,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tumbuh Bersama, Lebih Bermakna",
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.softPink,
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