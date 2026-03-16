import 'package:flutter/material.dart';

class MainanEdukasiScreen extends StatelessWidget {
  const MainanEdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA MAINAN EDUKASI (Referensi Alodokter) ---
    final List<Map<String, String>> daftarMainan = [
      {"nama": "Menyusun Balok (Blocks)", "manfaat": "Melatih koordinasi mata dan tangan, serta presisi saat anak menyeimbangkan satu balok di atas balok lainnya."},
      {"nama": "Bermain Lilin Mainan (Playdough)", "manfaat": "Membentuk, meremas, dan memilin playdough sangat bagus untuk memperkuat otot-otot jari tangan anak."},
      {"nama": "Mewarnai dan Menggambar", "manfaat": "Menggenggam krayon atau pensil warna adalah pondasi utama untuk melatih cara memegang alat tulis dengan benar."},
      {"nama": "Menyusun Puzzle", "manfaat": "Selain melatih pemecahan masalah (kognitif), gerakan mengambil dan mencocokkan kepingan puzzle akan melatih kelincahan jari."},
      {"nama": "Meronce Manik-manik", "manfaat": "Memasukkan benang ke dalam lubang manik-manik membutuhkan fokus tingkat tinggi dan kontrol otot jari yang sangat baik."},
      {"nama": "Melipat Kertas (Origami)", "manfaat": "Mengajarkan anak ketelitian, mengikuti instruksi bertahap, serta melatih keluwesan tangan saat melipat kertas."},
      {"nama": "Bermain Pasir Kinetik", "manfaat": "Memberikan stimulasi sensorik yang kaya sekaligus melatih otot tangan saat anak mencetak atau meratakan pasir."},
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
        title: Text("Mainan Edukasi", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER LOKAL ---
            // Nanti kalau kamu punya gambar lokal, ganti jadi Image.asset("assets/images/mainan.jpeg")
            Image.asset(
              "assets/images/mainan.png",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth:  800, // Optimasi ukuran gambar untuk performa lebih baik
            ),
            
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PENGANTAR ---
                  Text(
                    "Stimulasi Motorik Halus Lewat Bermain",
                    style: TextStyle(color: navyDark, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Motorik halus adalah kemampuan mengendalikan gerakan otot-otot kecil, khususnya pada tangan dan jari. Kemampuan ini sangat penting untuk kemandirian anak seperti makan sendiri, mengikat tali sepatu, hingga belajar menulis.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // --- LIST MAINAN ---
                  Text(
                    "Ide Permainan Edukatif",
                    style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(daftarMainan.length, (index) {
                    final item = daftarMainan[index];
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
                          Icon(Icons.extension_rounded, color: navyDark, size: 28),
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
                                  style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4),
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
                        Icon(Icons.medical_information_rounded, color: navyDark, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fakta Medis Ditinjau Oleh:",
                                style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tim Medis Alodokter\n(alodokter.com/permainan-yang-bisa-membangun-kemampuan-motorik-halus-anak)",
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