import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib import ini
import 'package:kawantumbuh/utils/app_colors.dart';
import 'package:kawantumbuh/widgets/custom_input.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color bgColor = const Color(0xFFFFD6D9);
  final Color textColor = const Color(0xFF2A365D);
  final Color fieldColor = const Color(0xFFEAA6A9);
  final Color btnColor = const Color(0xFF1B75A6);
  bool _rememberMe = false;

  // 1. Siapkan Controller untuk menangkap teks ketikan pengguna
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. Siapkan efek loading dan panggil Supabase
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  // 3. Fungsi untuk mengeksekusi Login ke Supabase
  Future<void> _login() async {
    // Validasi kalau kolom kosong
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No HP dan Password harus diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      
      // "Trik Ninja": Jadikan No HP sebagai Email palsu agar gratis
      final ninjaEmail = '$phone@kawantumbuh.com';

      // Proses tembak ke Supabase
      await supabase.auth.signInWithPassword(
        email: ninjaEmail,
        password: password,
      );

      // Kalau sukses, pindah ke Dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()), // Pastikan nama classnya benar
        );
      }
    } on AuthException catch (e) {
      // Muncul error kalau password salah atau akun belum terdaftar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal masuk: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan sistem"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              
              // --- INPUT NO HP ---
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  "No HP/Whatsapp",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: fieldColor, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  controller: _phoneController, // Sambungkan Controller di sini
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
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
              
              // --- INPUT PASSWORD ---
              // PERHATIAN: Kamu harus pastikan CustomInput milikmu bisa menerima parameter 'controller'
              CustomInput(
                label: "Password",
                hint: "*********",
                isPassword: true,
                controller: _passwordController, // Sambungkan Controller di sini
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
              
              // --- TOMBOL MASUK ---
              SizedBox(
                width: double.infinity,
                height: 50, // Sesuaikan tingginya biar proporsional
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Jalankan fungsi _login saat diklik
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oceanBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Samakan dengan TextField
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
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