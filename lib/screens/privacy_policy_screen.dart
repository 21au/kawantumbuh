import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA APLIKASI BUNDA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: softPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: navyDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Kebijakan Privasi",
          style: TextStyle(color: navyDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terakhir diperbarui: Maret 2026",
              style: TextStyle(color: navyDark.withOpacity(0.6), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("1. Pendahuluan", navyDark),
            _buildParagraph(
              "Selamat datang di Kawan Tumbuh. Kami sangat menghargai privasi Bunda dan si kecil. "
              "Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi ini.",
              navyDark,
            ),
            
            _buildSectionTitle("2. Informasi yang Kami Kumpulkan", navyDark),
            _buildParagraph(
              "Untuk memberikan pengalaman terbaik dalam memantau tumbuh kembang anak, kami mengumpulkan data berikut:\n"
              "• Informasi Akun (Nama, Email/Nomor HP, Foto Profil).\n"
              "• Data Anak (Nama, Tanggal Lahir, Jenis Kelamin, Berat Badan, Tinggi Badan, Lingkar Kepala).",
              navyDark,
            ),

            _buildSectionTitle("3. Penggunaan Informasi", navyDark),
            _buildParagraph(
              "Data yang kami kumpulkan hanya digunakan untuk:\n"
              "• Memantau grafik pertumbuhan anak sesuai standar WHO.\n"
              "• Menyediakan tips *parenting* dan artikel yang relevan dengan usia anak.\n"
              "• Menjaga keamanan akun Bunda.",
              navyDark,
            ),

            _buildSectionTitle("4. Keamanan Data", navyDark),
            _buildParagraph(
              "Kami berkomitmen untuk melindungi data Bunda dan si kecil. Data disimpan di peladen (server) yang aman dan kami tidak akan pernah menjual data Bunda kepada pihak ketiga mana pun.",
              navyDark,
            ),

            _buildSectionTitle("5. Hak Bunda (Penghapusan Data)", navyDark),
            _buildParagraph(
              "Bunda memiliki kendali penuh atas data Bunda. Bunda dapat mengubah informasi kapan saja melalui menu Profil, atau meminta penghapusan akun beserta seluruh data anak secara permanen melalui fitur 'Hapus Akun'.",
              navyDark,
            ),

            _buildSectionTitle("6. Hubungi Kami", navyDark),
            _buildParagraph(
              "Jika Bunda memiliki pertanyaan lebih lanjut terkait privasi data ini, silakan hubungi Bidan atau Admin Kawan Tumbuh melalui menu Pusat Bantuan (WhatsApp).",
              navyDark,
            ),
            
            const SizedBox(height: 40), // Jarak bawah biar nyaman di-scroll
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK TEKS ---
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withOpacity(0.8),
        fontSize: 14,
        height: 1.5, // Jarak antar baris biar enak dibaca
      ),
      textAlign: TextAlign.justify,
    );
  }
}