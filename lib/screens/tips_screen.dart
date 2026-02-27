import 'package:flutter/material.dart';
import 'detail_tips_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFFFC0CB), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2B4C),
        elevation: 0,
        // LEADING (TOMBOL BACK) SUDAH DIHAPUS
        automaticallyImplyLeading: false, // Memastikan tombol back bawaan tidak muncul
        title: const Text("Tips Kesehatan", 
          style: TextStyle(color: Color.fromARGB(255, 243, 216, 216), fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SEKSI CARI ARTIKEL
          Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            color: const Color(0xFF1A2B4C),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 196, 196),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari artikel kesehatan...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                  icon: Icon(Icons.search, color: Color(0xFFF69C91)),
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
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
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
                          width: 60, height: 60, color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    title: Text(
                      item['title']!, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['desc']!, maxLines: 1, overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(item['category']!, 
                          style: const TextStyle(color: Color(0xFFF69C91), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
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