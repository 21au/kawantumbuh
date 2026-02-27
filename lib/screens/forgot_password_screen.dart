import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter (Hanya Angka)
import 'package:kawantumbuh/utils/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali (Back) di pojok kiri atas
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Judul
              const Text(
                "Lupa Password?",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 17),
              // Sub-judul
              const Text(
                "Jangan khawatir, Bun. Masukkan nomor WhatsApp yang terdaftar untuk mengatur ulang sandi.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.navyDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Label Input
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  "No HP/Whatsapp",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              
              // Kolom Input (Hanya Angka)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAA6A9), // Sesuaikan warna field
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.number, // Membuka keyboard angka
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Mencegah huruf
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
              
              const SizedBox(height: 30),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Nanti kita atur fungsi kirim OTP-nya di sini
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oceanBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
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