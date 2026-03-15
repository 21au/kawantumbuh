import 'package:flutter/material.dart';
import 'detail_tips_screen.dart';
import 'kia/data_edukasi.dart'; // Sesuaikan jika lokasi foldernya berbeda

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA UTAMA (Disamakan dengan AnakScreen) ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA); // Background utama
    final Color fieldPink = const Color(0xFFF5CBCB); // Pengganti putih untuk kartu
    final Color highlightPink = const Color(0xFFEBA9A9); // Dusty pink

    // Data dummy tetap sama
    final List<Map<String, String>> daftarTips = [
      {
        "category": "Nutrisi", 
        "title": "10 Makanan Terbaik", 
        "desc": "Nutrisi lengkap untuk anak.", 
        "time": "5 mnt",
        "imageUrl": "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200"
      },
      {
        "category": "Perawatan", 
        "title": "Kualitas Tidur Bayi", 
        "desc": "Penting bagi otak bayi.", 
        "time": "8 mnt",
        "imageUrl": "https://images.unsplash.com/photo-1520206151081-9bf94ee04396?w=200"
      },
      {
        "category": "Stimulasi", 
        "title": "Mainan Edukasi", 
        "desc": "Rangsang motorik halus.", 
        "time": "6 mnt",
        "imageUrl": "https://images.unsplash.com/photo-1502086223501-7ea2443915b1?w=200"
      },
      {
        "category": "Kesehatan", 
        "title": "Jadwal Imunisasi", 
        "desc": "Kekebalan tubuh anak.", 
        "time": "10 mnt",
        "imageUrl": "https://images.unsplash.com/photo-1581594658553-359424894358?w=200"
      },
      {
        "category": "Tips", 
        "title": "Cara Mandi Bayi", 
        "desc": "Panduan aman mandi bayi.", 
        "time": "5 mnt",
        "imageUrl": "https://images.unsplash.com/photo-1515444744559-7be63e1600de?w=200"
      },
    ];

    return Scaffold(
      backgroundColor: softPink, // Menggunakan background utama
      appBar: AppBar(
        backgroundColor: navyDark, // Menggunakan navyDark
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Tips Kesehatan", 
          style: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SEKSI CARI ARTIKEL
          Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            color: navyDark, // Background section sama dengan AppBar
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: softPink, // Kolom pencarian pakai softPink
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: TextStyle(color: navyDark), // Warna teks saat ngetik
                decoration: InputDecoration(
                  hintText: "Cari artikel kesehatan...",
                  hintStyle: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 16),
                  icon: Icon(Icons.search, color: navyDark.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // LIST ARTIKEL
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: daftarTips.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = daftarTips[index];
                return Card(
                  color: fieldPink, // Kartu menggunakan fieldPink (pengganti putih)
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shadowColor: navyDark.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item['imageUrl']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cacheWidth: 120, 
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60, height: 60, color: highlightPink,
                          child: Icon(Icons.image, color: softPink),
                        ),
                      ),
                    ),
                    title: Text(
                      item['title']!, 
                      style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['desc']!, maxLines: 1, overflow: TextOverflow.ellipsis, 
                          style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(item['category']!, 
                          style: TextStyle(color: navyDark, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 12, color: navyDark.withOpacity(0.5)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailTipsScreen(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}