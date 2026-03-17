import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan package ini masih ada ya Bun

class PolaAsuhScreen extends StatelessWidget {
  const PolaAsuhScreen({super.key});

  // --- PALET WARNA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color fieldPink = const Color(0xFFF5CBCB);
  final Color highlightPink = const Color(0xFFEBA9A9);

  // --- FUNGSI BUKA LINK HALODOC ---
  Future<void> _bukaLinkHalodoc(BuildContext context) async {
    final Uri url = Uri.parse(
        'https://www.halodoc.com/kesehatan/pola-asuh-anak?srsltid=AfmBOoqAubt4fNnsz_KrTZ63rQQ1Qa55iJV0IgdehaJa-UoPST1_rP8_');
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka link');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka browser. Pastikan ada koneksi internet ya, Bun.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        elevation: 0,
        title: Text("Pola Asuh Anak", style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: softPink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER GAMBAR ---
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: fieldPink,
                image: const DecorationImage(
                  // Gambar ilustrasi pola asuh (bisa Bunda ganti dengan assets/images/ Bunda kalau ada)
                  image: NetworkImage('https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mengenal 4 Jenis Pola Asuh Anak",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Pola asuh atau parenting sangat berpengaruh pada karakter dan masa depan si Kecil. Menurut para ahli psikologi, secara umum ada 4 gaya pengasuhan yang sering diterapkan oleh orang tua:",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- DAFTAR POLA ASUH ---
                  _buildPolaAsuhCard(
                    title: "1. Pola Asuh Otoritatif (Demokratis)",
                    desc: "Sangat direkomendasikan! Orang tua memberikan batasan yang jelas, namun tetap responsif dan mau mendengarkan pendapat anak. Anak tumbuh menjadi mandiri, ceria, dan pandai bersosialisasi.",
                    icon: Icons.thumb_up_alt_rounded,
                    isRecommended: true,
                  ),
                  _buildPolaAsuhCard(
                    title: "2. Pola Asuh Otoriter",
                    desc: "Tipe pengasuhan yang kaku dan menuntut. Aturan dibuat tanpa kompromi (pokoknya harus nurut). Bisa membuat anak disiplin, namun rentan merasa tertekan, kurang percaya diri, atau suka berbohong.",
                    icon: Icons.gavel_rounded,
                  ),
                  _buildPolaAsuhCard(
                    title: "3. Pola Asuh Permisif",
                    desc: "Orang tua sangat hangat, tapi jarang memberikan aturan yang jelas. Anak dibebaskan melakukan apa saja. Dampaknya, anak bisa tumbuh kurang disiplin dan kesulitan mengikuti aturan di luar rumah.",
                    icon: Icons.child_care_rounded,
                  ),
                  _buildPolaAsuhCard(
                    title: "4. Pola Asuh Abaikan (Cuek)",
                    desc: "Orang tua tidak menuntut, tapi juga tidak responsif atau tidak peduli dengan kebutuhan emosional anak. Anak sering merasa tidak berharga dan kesulitan membangun hubungan dengan orang lain.",
                    icon: Icons.sentiment_dissatisfied_rounded,
                  ),

                  const SizedBox(height: 30),

                  // --- TOMBOL SUMBER HALODOC ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: navyDark.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_rounded, color: highlightPink, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "Ingin membaca lebih detail?",
                          style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Pelajari selengkapnya langsung dari artikel sumber terpercaya di Halodoc.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 12),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () => _bukaLinkHalodoc(context),
                          icon: Icon(Icons.open_in_browser_rounded, color: softPink),
                          label: Text("Baca Artikel Halodoc", style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyDark,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40), // Jarak bawah
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU POLA ASUH ---
  Widget _buildPolaAsuhCard({
    required String title,
    required String desc,
    required IconData icon,
    bool isRecommended = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isRecommended ? navyDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isRecommended)
            BoxShadow(color: navyDark.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRecommended ? highlightPink : fieldPink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isRecommended ? navyDark : navyDark, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isRecommended ? softPink : navyDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    color: isRecommended ? softPink.withOpacity(0.9) : navyDark.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}