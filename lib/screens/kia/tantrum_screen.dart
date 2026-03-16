import 'package:flutter/material.dart';

class TantrumScreen extends StatelessWidget {
  const TantrumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA JENIS TANTRUM (Ref: Siloam Hospitals) ---
    final List<Map<String, String>> jenisTantrum = [
      {
        "jenis": "1. Tantrum Manipulatif",
        "penjelasan": "Terjadi ketika keinginan anak ditolak atau tidak terpenuhi. Anak sengaja membuat ulah untuk memanipulasi orang tua agar menyerah dan menuruti kemauannya.",
        "ikon": "🎭"
      },
      {
        "jenis": "2. Tantrum Frustrasi",
        "penjelasan": "Terjadi karena anak merasa kelelahan, lapar, sakit, atau tidak bisa mengekspresikan apa yang ia rasakan. Ini murni karena anak kewalahan dengan emosinya sendiri.",
        "ikon": "🥺"
      },
    ];

    // --- DATA CARA MENGATASI ---
    final List<String> caraMengatasi = [
      "Tetap tenang dan jangan ikut terpancing emosi atau memarahi anak.",
      "Abaikan tantrum manipulatif. Jangan pernah menyerah atau menuruti keinginan anak saat ia sedang tantrum agar ia tidak menjadikannya senjata.",
      "Beri pelukan dan tenangkan anak jika ia mengalami tantrum frustrasi.",
      "Alihkan perhatiannya dengan mainan, buku, atau hal lain di sekitarnya.",
      "Pindahkan anak ke tempat yang aman dan jauhkan dari benda berbahaya saat ia berguling atau meronta.",
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
        title: Text("Mengatasi Tantrum", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER DARI UNSPLASH ---
            Image.asset(
              "assets/images/tantrum.jpeg",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800, // Optimasi ukuran gambar untuk performa lebih baik
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220, width: double.infinity, color: highlightPink,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_rounded, color: softPink, size: 40),
                    const SizedBox(height: 8),
                    Text("Gambar tidak ditemukan", style: TextStyle(color: softPink)),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Menghadapi Ledakan Emosi Si Kecil",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tantrum adalah ledakan emosi pada anak (biasanya usia 1-4 tahun) yang ditandai dengan menangis kencang, berguling, hingga berteriak. Ini sangat normal karena anak belum memiliki kosakata yang cukup untuk mengekspresikan perasaannya.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION JENIS TANTRUM ---
                  _buildSectionHeader(Icons.search_rounded, "Kenali Jenis Tantrum", navyDark),
                  const SizedBox(height: 15),
                  ...jenisTantrum.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: highlightPink.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["ikon"]!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["jenis"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(item["penjelasan"]!, style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),

                  // --- 2. SECTION CARA MENGATASI ---
                  _buildSectionHeader(Icons.check_circle_outline_rounded, "Solusi & Cara Mengatasi", navyDark),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: fieldPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: caraMengatasi.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.stars_rounded, color: navyDark.withOpacity(0.7), size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 14, height: 1.4))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- 3. SECTION VIDEO REKOMENDASI ---
                  _buildSectionHeader(Icons.play_circle_fill_rounded, "Video Edukasi", navyDark),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Nanti di sini bisa ditambahkan fungsi url_launcher untuk buka YouTube
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Membuka video YouTube..."),
                          backgroundColor: navyDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: navyDark,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: navyDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80, height: 55,
                            decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Cara Tepat Mengatasi Anak Tantrum", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Tonton panduan visual selengkapnya di YouTube.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- KOTAK SUMBER MEDIS ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: navyDark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_hospital_rounded, color: navyDark, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ditinjau Berdasarkan:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Artikel Medis Siloam Hospitals\n(Mengenal Jenis Tantrum pada Anak)", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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

  // --- WIDGET HELPER ---
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}