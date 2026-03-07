import 'package:flutter/material.dart';

class DetailTipsScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailTipsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA UTAMA (Disamakan dengan layar sebelumnya) ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA); 
    final Color highlightPink = const Color(0xFFEBA9A9); 

    return Scaffold(
      backgroundColor: softPink, // Background utama
      // Gunakan AppBar sederhana agar tombol back selalu responsif
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: navyDark,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: softPink, size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama dengan optimasi cache
            Image.network(
              item['imageUrl'] ?? '',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              cacheWidth: 600, 
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: highlightPink, // Pengganti warna abu-abu
                child: Icon(Icons.image, size: 50, color: softPink),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category']?.toUpperCase() ?? 'TIPS',
                    style: TextStyle(
                      color: navyDark.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      color: navyDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: navyDark.withOpacity(0.5)),
                      const SizedBox(width: 5),
                      Text(item['time'] ?? '5 mnt', style: TextStyle(color: navyDark.withOpacity(0.5))),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: navyDark.withOpacity(0.2)),
                  ),
                  // Teks Isi Artikel
                  Text(
                    item['desc'] ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: navyDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Menjaga kesehatan buah hati adalah prioritas utama setiap orang tua. "
                    "Pastikan Anda selalu berkonsultasi dengan tenaga medis profesional "
                    "untuk mendapatkan penanganan yang sesuai dengan kebutuhan spesifik anak Anda.\n\n"
                    "Langkah-langkah kecil yang dilakukan secara rutin akan memberikan dampak "
                    "besar bagi pertumbuhan fisik dan mental si kecil di masa depan.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: navyDark.withOpacity(0.9), // Pengganti Colors.black87
                    ),
                  ),
                  const SizedBox(height: 100), // Ruang agar tidak mentok bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}