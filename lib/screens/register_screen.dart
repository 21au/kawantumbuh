import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk filter input angka
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib
import 'package:kawantumbuh/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color bgColor = const Color(0xFFFFD6D9);
  final Color textColor = const Color(0xFF2A365D);
  final Color fieldColor = const Color(0xFFEAA6A9);
  final Color btnColor = const Color(0xFF1B75A6);

  // 1. Siapkan Controller untuk menangkap teks
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Siapkan efek loading dan panggil Supabase
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  // 3. Fungsi untuk mengeksekusi Daftar Akun ke Supabase
  Future<void> _register() async {
    // Validasi agar kolom tidak ada yang kosong
    if (_phoneController.text.isEmpty || 
        _nameController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom harus diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    // Validasi password minimal 6 karakter
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();
      
      // "Trik Ninja": Jadikan No HP sebagai Email palsu
      final ninjaEmail = '$phone@kawantumbuh.com';

      // Proses tembak ke Supabase untuk daftar
      await supabase.auth.signUp(
        email: ninjaEmail,
        password: password,
        // Menyimpan data tambahan seperti Nama
        data: {'full_name': name, 'phone': phone},
      );

      // Kalau sukses daftar, kembali ke halaman Login dengan pesan sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pendaftaran berhasil! Silakan Login."), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendaftar: ${e.message}"), backgroundColor: Colors.red),
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
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Silakan Daftar!',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Jika anda belum memiliki akun daftar\ndisini',
                style: TextStyle(
                  fontSize: 17,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Form No HP/Whatsapp
              _buildLabel('No HP/Whatsapp'),
              _buildTextField(
                hintText: '081234567890', 
                controller: _phoneController, // Sambungkan controller
                isPhone: true, // Beri tanda ini form nomor HP
              ),
              const SizedBox(height: 20),

              // Form Nama
              _buildLabel('Nama'),
              _buildTextField(
                hintText: 'Bunda Sarah', 
                controller: _nameController, // Sambungkan controller
              ),
              const SizedBox(height: 20),

              // Form Password
              _buildLabel('Password'),
              _buildTextField(
                hintText: 'minimal 6 karakter', 
                isPassword: true,
                controller: _passwordController, // Sambungkan controller
              ),
              const SizedBox(height: 40),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _register, // Eksekusi fungsi register
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 18, // Sedikit dibesarkan biar sama dengan login
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Ubah ke putih biar kontras
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 30),

              // Teks Tambahan: Sudah Punya Akun -> Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah memiliki akun? ',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: btnColor, 
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

  // --- WIDGET BANTUAN --- 
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // Widget Bantuan dimodifikasi agar bisa menerima controller dan format angka
  Widget _buildTextField({
    required String hintText, 
    bool isPassword = false, 
    bool isPhone = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller, // Pemasangan controller
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text, // Munculkan numpad jika HP
        inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null, // Blokir huruf jika HP
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}