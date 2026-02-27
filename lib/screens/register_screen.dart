import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Warna utama yang diambil dari desainmu
  final Color bgColor = const Color(0xFFFFD6D9); // Pink pastel background
  final Color textColor = const Color(0xFF2A365D); // Biru tua untuk teks
  final Color fieldColor = const Color(0xFFEAA6A9); // Pink sedikit gelap untuk kolom
  final Color btnColor = const Color(0xFF1B75A6); // Biru untuk tombol

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // SingleChildScrollView agar layar bisa di-scroll (tidak error kalau keyboard muncul)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Judul
              Text(
                'Silakan Daftar!',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              // Sub-judul
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
              _buildTextField(hintText: '081234567890'), // Contoh nomor, nanti bisa diganti sesuai kebutuhan
              const SizedBox(height: 20),

              // Form Nama
              _buildLabel('Nama'),
              _buildTextField(hintText: 'Audrey Pramudita S'),
              const SizedBox(height: 20),

              // Form Password
              _buildLabel('Password'),
              _buildTextField(hintText: '********', isPassword: true),
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
                  onPressed: () {
                    // Nanti kita isi aksi untuk mengirim data ke backend
                  },
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bgColor, // Warna teks tombol menyesuaikan pink background
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );// Nanti di sini kita arahkan ke halaman Login
                      print("Pergi ke halaman login");
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: btnColor, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline, // Memberi garis bawah agar jelas bisa diklik
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
  // Agar kode lebih rapi, kita pisahkan kode pembuatan Label Teks di sini
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

  // Widget Bantuan untuk Kolom Isian (TextField) beserta efek bayangannya (Shadow)
  Widget _buildTextField({required String hintText, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Efek bayangan seperti di desain
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword, // Kalau password, teksnya jadi bintang-bintang
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
          border: InputBorder.none, // Menghilangkan garis bawaan flutter
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}