import 'package:flutter/material.dart';

class TidurScreen extends StatelessWidget {
  const TidurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA KEBUTUHAN TIDUR (Sesuai Panduan IDAI) ---
    final List<Map<String, String>> kebutuhanTidur = [
      {"usia": "0 - 3 Bulan", "waktu": "14 - 17 Jam", "desc": "Bayi baru lahir belum memiliki ritme sirkadian (pola siang-malam). Mereka akan sering terbangun setiap 2-3 jam untuk menyusu."},
      {"usia": "4 - 11 Bulan", "waktu": "12 - 15 Jam", "desc": "Pola tidur mulai teratur. Membutuhkan sekitar 10-12 jam di malam hari dan 2-3 kali tidur siang yang lebih terprediksi."},
      {"usia": "1 - 2 Tahun", "waktu": "11 - 14 Jam", "desc": "Anak batita biasanya mulai beralih ke satu kali tidur siang selama 1-2 jam, dan sisanya difokuskan pada tidur malam."},
      {"usia": "3 - 5 Tahun", "waktu": "10 - 13 Jam", "desc": "Anak usia prasekolah mungkin mulai melewatkan tidur siang, namun rutinitas tidur malam yang konsisten sangat diperlukan."},
    ];

    // --- DATA TIPS TIDUR NYENYAK ---
    final List<Map<String, String>> tipsTidur = [
      {"judul": "Kenali Tanda Mengantuk (Sleep Cues)", "isi": "Jangan tunggu sampai bayi menangis atau *overtired*. Tanda awal: menggosok mata, menguap, tatapan kosong, atau menarik telinga."},
      {"judul": "Terapkan Sleep Hygiene", "isi": "Pastikan suhu ruangan sejuk (idealnya 20-22°C), redupkan lampu untuk memicu hormon melatonin, dan gunakan *white noise* jika lingkungan bising."},
      {"judul": "Rutinitas Sebelum Tidur (Bedtime Routine)", "isi": "Lakukan pola yang sama setiap malam 30 menit sebelum tidur: Mandi air hangat, ganti baju tidur, bacakan buku, dan susui."},
      {"judul": "Hindari Stimulasi Berlebih & Layar", "isi": "Hentikan aktivitas bermain yang terlalu aktif dan jauhkan paparan layar (HP/TV) minimal 1-2 jam sebelum jadwal tidurnya."},
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
        title: Text("Kualitas Tidur Bayi", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER LOKAL ---
            // Kode loadingBuilder sudah dihapus karena gambar lokal tidak membutuhkannya
            Image.asset(
              "assets/images/tidur.jpeg",
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
                    "Pentingnya Tidur untuk Tumbuh Kembang",
                    style: TextStyle(color: navyDark, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tidur yang berkualitas sangat krusial. Saat anak tertidur lelap (fase *Deep Sleep*), hormon pertumbuhan diproduksi maksimal, sistem imun diperkuat, dan otak mengonsolidasi memori memproses apa yang dipelajari seharian.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // --- SEKSI KEBUTUHAN TIDUR ---
                  Text(
                    "Jam Tidur Ideal Sesuai Usia",
                    style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(kebutuhanTidur.length, (index) {
                    final item = kebutuhanTidur[index];
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
                          Icon(Icons.access_time_filled_rounded, color: navyDark, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item["usia"]!, style: TextStyle(color: navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                                   Text(item["waktu"]!, style: TextStyle(color: Colors.pinkAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item["desc"]!, style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // --- SEKSI TIPS TIDUR NYENYAK ---
                  Text(
                    "Tips Anak Cepat Tidur Nyenyak",
                    style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(tipsTidur.length, (index) {
                    final item = tipsTidur[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: highlightPink, width: 4)),
                        color: navyDark.withOpacity(0.03),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["judul"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(item["isi"]!, style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13, height: 1.4)),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 25),

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
                        Icon(Icons.menu_book_rounded, color: navyDark, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Referensi & Fakta Medis:",
                                style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Ikatan Dokter Anak Indonesia (IDAI)\n(idai.or.id/artikel/klinik/pengasuhan-anak/kebutuhan-tidur-pada-anak)",
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