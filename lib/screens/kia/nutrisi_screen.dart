import 'package:flutter/material.dart';

class NutrisiScreen extends StatelessWidget {
  const NutrisiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        title: const Text("Panduan Nutrisi Anak"),
        centerTitle: true,
        iconTheme: IconThemeData(color: softPink),
        titleTextStyle: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80",
              width: double.infinity, height: 250, fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KOTAK SUMBER MEDIS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: navyDark.withOpacity(0.1),
                      border: Border(left: BorderSide(color: navyDark, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: navyDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Ditinjau berdasarkan pedoman resmi IDAI (Ikatan Dokter Anak Indonesia) dan Kemenkes RI.",
                            style: TextStyle(color: navyDark, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text("Pemenuhan Nutrisi untuk Mencegah Stunting", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navyDark, height: 1.3)),
                  const SizedBox(height: 15),
                  Text(
                    "Pemberian makanan yang tepat sejak fase MPASI (Mulai usia 6 bulan) sangat menentukan pertumbuhan kecerdasan otak dan fisik anak. Kemenkes sangat menekankan pentingnya asupan Protein Hewani setiap hari.",
                    style: TextStyle(fontSize: 16, color: navyDark.withOpacity(0.9), height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  Text("Komponen Wajib MPASI (IDAI)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navyDark)),
                  const SizedBox(height: 10),
                  
                  _buildListPoint("Karbohidrat", "Nasi, kentang, jagung, atau ubi sebagai sumber energi utama.", Icons.rice_bowl),
                  _buildListPoint("Protein Hewani (SANGAT PENTING)", "Daging ayam, daging sapi, hati ayam, ikan, atau telur. Ini adalah kunci utama mencegah stunting karena kaya akan zat besi.", Icons.set_meal),
                  _buildListPoint("Lemak Tambahan", "Minyak kelapa, santan, mentega tak tawar (unsalted butter), atau minyak zaitun untuk menambah berat badan bayi.", Icons.water_drop),
                  _buildListPoint("Sayur & Buah", "Diberikan dalam jumlah sedikit (hanya untuk pengenalan rasa), karena serat berlebih bisa membuat bayi cepat kenyang namun kurang kalori.", Icons.eco),

                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Sumber Referensi:\nBuku KIA Kemenkes RI Edisi 2023\nSitus Resmi IDAI (idai.or.id)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: navyDark.withOpacity(0.5), fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListPoint(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF102C57), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102C57))),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: const Color(0xFF102C57).withOpacity(0.8), fontSize: 15, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}