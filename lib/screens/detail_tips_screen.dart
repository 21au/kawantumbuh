import 'package:flutter/material.dart';

class DetailTipsScreen extends StatelessWidget {
  // PERBAIKAN 1: Tipe data diubah menjadi dynamic
  final Map<String, dynamic> item;

  const DetailTipsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA UTAMA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA); 
    final Color highlightPink = const Color(0xFFEBA9A9); 

    return Scaffold(
      backgroundColor: softPink, 
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
            
            // PERBAIKAN 2: Logika pintar untuk membedakan gambar internet & lokal
            Builder(
              builder: (context) {
                String imagePath = item['imageUrl'] ?? '';
                
                // Jika gambar dari internet (URL)
                if (imagePath.startsWith('http')) {
                  return Image.network(
                    imagePath,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300, color: highlightPink,
                      child: Icon(Icons.image, size: 50, color: softPink),
                    ),
                  );
                } 
                // Jika gambar dari aset folder lokal (Buku KIA)
                else if (imagePath.isNotEmpty) {
                  return Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300, color: highlightPink,
                      child: Icon(Icons.image_not_supported, size: 50, color: softPink),
                    ),
                  );
                }
                // Jika tidak ada gambar
                return Container(
                  height: 300, color: highlightPink,
                  child: Icon(Icons.image, size: 50, color: softPink),
                );
              },
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
                  
                  // PERBAIKAN 3: Memanggil Teks dari Bank Data
                  // Menampilkan deskripsi (kalau ada)
                  if (item['desc'] != null)
                    Text(
                      item['desc'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: navyDark,
                      ),
                    ),
                  if (item['desc'] != null) const SizedBox(height: 15),
                  
                  // Menampilkan isi artikel lengkap
                  Text(
                    item['content'] ?? 'Konten belum tersedia.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: navyDark.withOpacity(0.9), 
                    ),
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}