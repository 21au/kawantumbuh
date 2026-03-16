import 'package:flutter/material.dart';

class MandiScreen extends StatelessWidget {
  const MandiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA LENGKAP (Referensi RS Hermina) ---
    final List<String> tujuanMandi = [
      "Membersihkan kulit dari darah, feses, air ketuban, dan verniks (lapisan putih).",
      "Memberikan rasa nyaman dan rileks pada bayi.",
      "Merangsang peredaran darah yang sehat.",
      "Mencegah infeksi pada kulit dan tali pusat.",
      "Momen bonding (ikatan batin) antara ibu dan si Kecil.",
    ];

    final List<String> persiapanAlat = [
      "Bak mandi berisi air hangat kuku (2/3 bagian).",
      "Sabun dan sampo khusus bayi.",
      "2 buah waslap lembut.",
      "Handuk kering dan bersih.",
      "Pakaian ganti bayi lengkap.",
      "Kassa steril kering (untuk tali pusat).",
      "Kapas bulat (direndam air hangat/panas).",
      "Tempat tidur dengan alas perlak.",
    ];

    final List<Map<String, String>> langkahMandi = [
      {"langkah": "Cuci Tangan", "penjelasan": "Mencuci tangan sebelum dan sesudah memegang bayi."},
      {"langkah": "Bersihkan Mata", "penjelasan": "Gunakan kapas bulat hangat. Usap dari pangkal hidung ke ujung mata luar. Wajib 1x usap searah (jangan bolak-balik)."},
      {"langkah": "Basuh Wajah", "penjelasan": "Bersihkan muka bayi secara lembut menggunakan waslap basah tanpa sabun."},
      {"langkah": "Mandi di Bak", "penjelasan": "Gunakan sabun & sampo. Selipkan lengan Anda di bawah leher/bahu bayi, pegang dengan hati-hati agar tidak licin atau jatuh."},
      {"langkah": "Keringkan Tubuh", "penjelasan": "Angkat bayi ke atas handuk. Tepuk-tepuk lembut seluruh tubuh dan lipatan kulit hingga benar-benar kering. Sambil cek apakah ada kelainan kulit."},
      {"langkah": "Rawat Tali Pusat", "penjelasan": "Bungkus tali pusat bayi menggunakan kassa steril yang kering (jangan diberi betadine/alkohol tanpa anjuran dokter)."},
      {"langkah": "Kenakan Pakaian", "penjelasan": "Segera pakaikan baju, popok, dan bedong (jika perlu) agar bayi tetap merasa hangat dan nyaman."},
    ];

    final List<String> peringatanPenting = [
      "Jangan pernah meninggalkan bayi sendirian di bak mandi, sedetik pun!",
      "Cek suhu air menggunakan siku atau pergelangan tangan bagian dalam ibu.",
      "Pastikan suhu ruangan tetap hangat dan tidak ada angin kencang.",
      "Jangan menggosok kulit bayi terlalu keras saat mengeringkan badan.",
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
        title: Text("Cara Mandi Bayi", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER ---
            Image.asset(
              "assets/images/mandi.png",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
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
                    "Panduan Lengkap Memandikan Si Kecil",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION TUJUAN ---
                  _buildSectionHeader(Icons.flag_rounded, "Tujuan Memandikan Bayi", navyDark),
                  const SizedBox(height: 10),
                  ...tujuanMandi.map((item) => _buildBulletPoint(item, navyDark)),
                  const SizedBox(height: 25),

                  // --- 2. SECTION PERSIAPAN ALAT ---
                  _buildSectionHeader(Icons.shopping_bag_rounded, "Persiapan Alat Mandi", navyDark),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: persiapanAlat.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: highlightPink, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item, style: TextStyle(color: navyDark, fontSize: 14))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. SECTION LANGKAH-LANGKAH ---
                  _buildSectionHeader(Icons.format_list_numbered_rounded, "Langkah-Langkah", navyDark),
                  const SizedBox(height: 15),
                  ...List.generate(langkahMandi.length, (index) {
                    final item = langkahMandi[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: fieldPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: navyDark,
                            radius: 16,
                            child: Text("${index + 1}", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item["langkah"]!, style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(item["penjelasan"]!, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 15),

                  // --- 4. SECTION HAL YANG PERLU DIINGAT (WARNING BOX) ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5), // Warna kuning/orange pastel untuk peringatan
                      border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00), size: 24),
                            const SizedBox(width: 10),
                            Text("Penting Diingat!", style: TextStyle(color: const Color(0xFFF57C00), fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...peringatanPenting.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(color: Color(0xFFF57C00), fontSize: 16, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(item, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4))),
                            ],
                          ),
                        )),
                      ],
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
                              Text("Artikel RS Hermina (Cara Memandikan Bayi yang Benar)", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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

  // --- WIDGET HELPER UNTUK MENGURANGI KODE BERULANG ---
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6, height: 6,
            decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: color.withOpacity(0.9), fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}