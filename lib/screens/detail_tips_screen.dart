import 'package:flutter/material.dart';

class DetailTipsScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailTipsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Warna tema agar konsisten
    const Color navyBackground = Color(0xFF1A2B4C);
    const Color offWhitePink = Color.fromARGB(255, 231, 183, 187);

    return Scaffold(
      backgroundColor: offWhitePink,
      // Gunakan AppBar sederhana agar tombol back selalu responsif
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: navyBackground,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 235, 185, 185), size: 18),
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
              // KUNCI: Batasi memori gambar di sini
              cacheWidth: 600, 
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category']?.toUpperCase() ?? 'TIPS',
                    style: const TextStyle(
                      color: Color(0xFFF69C91),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      color: navyBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(item['time'] ?? '5 mnt', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  // Teks Isi Artikel (Dummy)
                  Text(
                    item['desc'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: navyBackground,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Menjaga kesehatan buah hati adalah prioritas utama setiap orang tua. "
                    "Pastikan Anda selalu berkonsultasi dengan tenaga medis profesional "
                    "untuk mendapatkan penanganan yang sesuai dengan kebutuhan spesifik anak Anda.\n\n"
                    "Langkah-langkah kecil yang dilakukan secara rutin akan memberikan dampak "
                    "besar bagi pertumbuhan fisik dan mental si kecil di masa depan.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
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