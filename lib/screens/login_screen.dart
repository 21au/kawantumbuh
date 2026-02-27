import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib ditambahkan untuk membatasi input hanya angka
import 'package:kawantumbuh/utils/app_colors.dart';
import 'package:kawantumbuh/widgets/custom_input.dart';
import 'register_screen.dart'; // Import halaman register
import 'forgot_password_screen.dart'; // Import halaman lupa password (kita buat setelah ini)
import 'dashboard_screen.dart'; // Tambahkan baris ini

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
   final Color bgColor = const Color(0xFFFFD6D9); // Pink pastel background
  final Color textColor = const Color(0xFF2A365D); // Biru tua untuk teks
  final Color fieldColor = const Color(0xFFEAA6A9); // Pink sedikit gelap untuk kolom
  final Color btnColor = const Color(0xFF1B75A6); // Biru untuk tombol
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Selamat Datang!",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                "Pantau tumbuh kembang si kecil dengan mudah.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 40),
              
              // --- INPUT NO HP (Hanya Angka) ---
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  "No HP/Whatsapp",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAA6A9), // Sesuaikan dengan warna custom input-mu
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.number, // Memunculkan keyboard angka di HP
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Mencegah huruf diketik (walau pakai keyboard fisik)
                  ],
                  style: const TextStyle(color: AppColors.navyDark),
                  decoration: InputDecoration(
                    hintText: "081234567890",
                    hintStyle: TextStyle(color: AppColors.navyDark.withOpacity(0.6), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Input Password (Tetap pakai CustomInput milikmu)
              const CustomInput(
                label: "Password",
                hint: "*********",
                isPassword: true,
              ),
              
              const SizedBox(height: 15),
              
              // Ingatkan Saya & Lupa Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.oceanBlue,
                        onChanged: (value) {
                          setState(() => _rememberMe = value!);
                        },
                      ),
                      const Text("Ingatkan Saya", style: TextStyle(color: AppColors.navyDark)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Pindah ke halaman Lupa Password
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Lupa password?",
                      style: TextStyle(color: AppColors.navyDark, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Trik Frontend: Langsung pindah ke Dashboard!
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oceanBlue,
                    // ... (sisa kodenya tetap sama) ...
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Teks Belum Punya Akun -> Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum memiliki akun? ",
                    style: TextStyle(color: AppColors.navyDark, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Pindah ke halaman Register
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Daftar disini",
                      style: TextStyle(
                        color: AppColors.oceanBlue, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}