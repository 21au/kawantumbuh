import 'package:flutter/material.dart';

class MakananTerbaikScreen extends StatelessWidget {
  const MakananTerbaikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA 10 SUPERFOOD (Berdasarkan Fakta Medis) ---
    final List<Map<String, String>> daftarMakanan = [
      {"nama": "Telur", "manfaat": "Mengandung protein tinggi, zat besi, dan kolin yang sangat penting untuk perkembangan otak dan memori anak."},
      {"nama": "Alpukat", "manfaat": "Kaya akan lemak tak jenuh (lemak baik) yang menyehatkan jantung, otak, dan membantu menaikkan berat badan bayi secara sehat."},
      {"nama": "Ikan Salmon", "manfaat": "Sumber utama Omega-3 dan DHA yang sangat krusial untuk perkembangan sistem saraf dan kecerdasan otak."},
      {"nama": "Ubi Jalar", "manfaat": "Memiliki rasa manis alami, kaya akan Vitamin C, Vitamin A (beta-karoten), dan serat untuk kesehatan mata & pencernaan."},
      {"nama": "Susu dan Yoghurt", "manfaat": "Tinggi kalsium dan vitamin D untuk pembentukan tulang dan gigi. Yoghurt juga kaya probiotik untuk usus."},
      {"nama": "Sayuran Hijau (Bayam/Brokoli)", "manfaat": "Superfood yang sarat dengan folat, zat besi, dan antioksidan untuk mencegah anemia dan meningkatkan imun."},
      {"nama": "Daging Sapi (Tanpa Lemak)", "manfaat": "Sumber zinc dan zat besi heme (mudah diserap tubuh) terbaik yang dianjurkan untuk mencegah stunting."},
      {"nama": "Kacang-kacangan & Biji-bijian", "manfaat": "Sumber protein nabati, zat besi, dan serat. Tempe dan tahu juga sangat baik untuk selingan MPASI."},
      {"nama": "Buah Beri (Strawberry/Blueberry)", "manfaat": "Mengandung antioksidan dan Vitamin C yang sangat tinggi untuk menjaga daya tahan tubuh si Kecil."},
      {"nama": "Oatmeal", "manfaat": "Karbohidrat kompleks yang memberikan energi tahan lama dan serat tinggi agar pencernaan bayi lancar."},
    ];

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: softPink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("10 Makanan Terbaik", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER ---
            Image.network(
              "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=800&q=80",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PENGANTAR ---
                  Text(
                    "Superfood untuk Tumbuh Kembang Si Kecil",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Memasuki masa MPASI, si Kecil membutuhkan nutrisi yang jauh lebih besar untuk mendukung perkembangan otak dan fisiknya. Berikut adalah 10 bahan makanan 'Superfood' yang wajib ada dalam menu harian buah hati Anda.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // --- LIST MAKANAN (Dibangun manual agar bisa di dalam ScrollView) ---
                  ...List.generate(daftarMakanan.length, (index) {
                    final item = daftarMakanan[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: fieldPink,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: navyDark.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: navyDark,
                            radius: 18,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["nama"]!,
                                  style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item["manfaat"]!,
                                  style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 14, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // --- KOTAK SUMBER FAKTA MEDIS ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: navyDark.withOpacity(0.05),
                      border: Border.all(color: highlightPink, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.health_and_safety, color: navyDark, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fakta Medis Ditinjau Dari:",
                                style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Artikel Kesehatan Ciputra Hospital\n(ciputrahospital.com/superfood-untuk-tumbuh-kembang-bayi/)",
                                style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 12, height: 1.4, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}