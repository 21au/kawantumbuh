import 'package:flutter/material.dart';

class KeterlambatanBicaraScreen extends StatelessWidget {
  const KeterlambatanBicaraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA RED FLAGS (TANDA BAHAYA) ---
    final List<Map<String, String>> redFlags = [
      {
        "usia": "Usia 12 Bulan",
        "tanda": "Bayi belum menunjuk dengan jari, belum merespons saat namanya dipanggil, atau belum mulai mengoceh (babbling) seperti 'ma-ma' atau 'ba-ba'.",
        "ikon": "👶"
      },
      {
        "usia": "Usia 18 Bulan",
        "tanda": "Belum ada 1 pun kata bermakna yang diucapkan secara jelas (seperti 'mama', 'papa', atau 'susu'). Anak lebih sering menunjuk diam-diam daripada mencoba bersuara.",
        "ikon": "🧸"
      },
      {
        "usia": "Usia 24 Bulan (2 Tahun)",
        "tanda": "Belum bisa merangkai 2 kata (contoh: 'mau makan' atau 'mama pergi'), perbendaharaan kosakata kurang dari 50 kata, dan bicaranya masih sulit dipahami oleh orang terdekat.",
        "ikon": "🧒"
      },
    ];

    // --- DATA CARA STIMULASI ---
    final List<String> caraStimulasi = [
      "Sering ajak anak mengobrol setiap hari, ceritakan apa yang sedang Ibu lakukan (misal: 'Wah, Ibu sedang potong wortel warna jingga!').",
      "Bacakan buku cerita atau dongeng sebelum tidur. Ini sangat ampuh menambah kosakata anak.",
      "Hindari gadget/TV (screen time) pada anak di bawah usia 2 tahun. Terlalu banyak menonton bisa menghambat interaksi dua arah.",
      "Gunakan bahasa tubuh dan respons setiap celotehan anak, meskipun belum jelas maknanya.",
      "Ajari menyanyi lagu anak-anak bersama untuk melatih artikulasi dengan cara yang menyenangkan."
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
        title: Text("Keterlambatan Bicara", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER DARI UNSPLASH ---
            Image.network(
              "https://images.unsplash.com/photo-1544126592-807ade215a0b?auto=format&fit=crop&w=800&q=80",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220, width: double.infinity, color: highlightPink,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: softPink, size: 40),
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
                  // --- PENGANTAR ---
                  Text(
                    "Mengenal Bahaya Speech Delay",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Speech delay (keterlambatan bicara) adalah kondisi ketika kemampuan bicara dan bahasa anak tidak berkembang sesuai usianya. Hal ini tidak boleh diabaikan karena bisa berdampak pada kemampuan belajar dan sosialisasi anak kelak.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION RED FLAGS ---
                  _buildSectionHeader(Icons.flag_rounded, "Waspadai Tanda Ini (Red Flags)", navyDark),
                  const SizedBox(height: 15),
                  ...redFlags.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: fieldPink,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: highlightPink.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["ikon"]!, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["usia"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(item["tanda"]!, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 25),

                  // --- 2. SECTION CARA STIMULASI ---
                  _buildSectionHeader(Icons.lightbulb_outline_rounded, "Tips Stimulasi di Rumah", navyDark),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: caraStimulasi.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_rounded, color: highlightPink, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 14, height: 1.4))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- 3. SECTION KAPAN KE DOKTER (WARNING BOX) ---
                  _buildSectionHeader(Icons.warning_rounded, "Kapan Harus ke Dokter?", const Color(0xFFD32F2F)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(color: const Color(0xFFEF5350), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jangan menunggu sampai anak lebih besar!", 
                          style: TextStyle(color: const Color(0xFFC62828), fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 8),
                        const Text(
                          "Jika Ibu menemukan salah satu tanda bahaya di atas, atau jika anak tiba-tiba kehilangan kemampuan bicara yang sebelumnya sudah ia kuasai (kemunduran), segera jadwalkan konsultasi dengan Dokter Spesialis Anak (Klinik Tumbuh Kembang).",
                          style: TextStyle(color: Color(0xFFB71C1C), fontSize: 13, height: 1.4),
                        )
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
                              Text("Artikel RS Hermina\n(Ketahui Bahaya Speech Delay Pada Anak)", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold))),
      ],
    );
  }
}