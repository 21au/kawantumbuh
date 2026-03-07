import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  // --- DEFINISI WARNA (Sama dengan Login & Register) ---
  final Color bgColor = const Color(0xFFFFEAEA);
  final Color navyDark = const Color(0xFF102C57);
  final Color fieldColor = const Color(0xFFF5CBCB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali yang warnanya sudah disesuaikan
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navyDark, size: 20),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Judul Utama
              Text(
                "Lupa Password?",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: navyDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 15),
              // Pesan untuk Bunda
              Text(
                "Jangan khawatir, Bun. Masukkan nomor WhatsApp yang terdaftar untuk mengatur ulang sandi.",
                style: TextStyle(
                  fontSize: 15,
                  color: navyDark.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 45),

              // Label Input
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  "No HP/Whatsapp",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: navyDark,
                  ),
                ),
              ),
              
              // Kolom Input (Desain sama dengan Login)
              Container(
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(color: navyDark, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "081234567890",
                    hintStyle: TextStyle(
                      color: navyDark.withOpacity(0.4), 
                      fontSize: 14
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              // Tombol Kirim yang mantap
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika OTP atau reset password nanti di sini
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyDark,
                    elevation: 4,
                    shadowColor: navyDark.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Kirim Kode Verifikasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}