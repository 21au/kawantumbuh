import 'package:flutter/material.dart';

class MerawatGigiSusuScreen extends StatelessWidget {
  const MerawatGigiSusuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA PERAWATAN GIGI ---
    final List<Map<String, String>> langkahPerawatan = [
      {
        "tahap": "1. Sebelum Gigi Tumbuh (0-6 Bulan)",
        "cara": "Meskipun gigi belum muncul, gusi bayi tetap harus dibersihkan. Gunakan kain kasa basah atau waslap bersih yang lembut untuk menyeka gusi bayi setidaknya 2 kali sehari (terutama setelah menyusu sebelum tidur).",
        "ikon": "🧽"
      },
      {
        "tahap": "2. Saat Gigi Pertama Muncul (6+ Bulan)",
        "cara": "Mulai gunakan sikat gigi bayi berbulu sangat lembut. Gunakan pasta gigi ber-Fluoride seukuran biji beras (selapis tipis saja). Sikat gigi 2 kali sehari, pagi setelah sarapan dan malam sebelum tidur.",
        "ikon": "🪥"
      },
      {
        "tahap": "3. Saat Anak Berusia 3 Tahun",
        "cara": "Tingkatkan jumlah pasta gigi ber-Fluoride menjadi seukuran biji kacang polong. Ajari anak untuk meludah setelah menyikat gigi, tapi jangan langsung berkumur dengan air agar Fluoride bisa melindungi gigi.",
        "ikon": "🪥"
      },
    ];

    // --- DATA PANTANGAN / KEBUTUHAN ---
    final List<String> pantangan = [
      "Jangan biarkan anak tidur sambil mengempeng botol susu (dot) di mulutnya. Genangan susu di sekitar gigi semalaman adalah penyebab utama 'Gigi Gigis' (Karies Botol).",
      "Hindari mencelupkan dot ke dalam madu, gula, atau sirup.",
      "Kurangi camilan manis dan lengket (seperti permen atau biskuit manis) di antara jam makan utama.",
      "Kunjungan pertama ke dokter gigi anak sebaiknya dilakukan saat gigi pertama tumbuh, atau maksimal saat anak berusia 1 tahun.",
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
        title: Text("Merawat Gigi Susu", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER ---
            Image.network(
              "https://images.unsplash.com/photo-1606811841689-23dfddce3e95?auto=format&fit=crop&w=800&q=80",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220, width: double.infinity, color: highlightPink,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face_retouching_natural_rounded, color: softPink, size: 40),
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
                    "Gigi Susu Sehat, Senyum Si Kecil Hebat!",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Gigi susu tidak hanya berfungsi untuk mengunyah makanan, tapi juga penting untuk perkembangan bicara dan sebagai 'penahan ruang' (space maintainer) agar gigi tetap nantinya bisa tumbuh rapi pada tempatnya.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION LANGKAH PERAWATAN ---
                  _buildSectionHeader(Icons.clean_hands_rounded, "Tahapan Perawatan Gigi", navyDark),
                  const SizedBox(height: 15),
                  ...langkahPerawatan.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
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
                              Text(item["tahap"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(item["cara"]!, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 25),

                  // --- 2. SECTION PENCEGAHAN (WARNING BOX) ---
                  _buildSectionHeader(Icons.healing_rounded, "Cegah Karies Botol (Gigi Gigis)", const Color(0xFFD32F2F)),
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
                        Text("Penting diperhatikan oleh Ibu & Ayah:", 
                          style: TextStyle(color: const Color(0xFFC62828), fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 12),
                        ...pantangan.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("🚫 ", style: TextStyle(fontSize: 14)),
                              Expanded(child: Text(item, style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13, height: 1.4))),
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
                        Icon(Icons.verified_user_rounded, color: navyDark, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Panduan Kesehatan:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Berdasarkan anjuran IDAI (Ikatan Dokter Anak Indonesia) & Dokter Gigi Anak", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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