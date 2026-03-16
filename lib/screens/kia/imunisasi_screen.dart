import 'package:flutter/material.dart';

class ImunisasiScreen extends StatelessWidget {
  const ImunisasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA UTAMA (Sesuai dengan Dashboard) ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA JADWAL IMUNISASI ---
    // Data ini mengacu pada standar umum IDAI/Kemenkes. 
    // Bisa kamu sesuaikan lagi teksnya persis seperti di gambar referensimu.
    final List<Map<String, dynamic>> jadwalImunisasi = [
      {
        "usia": "0 Bulan (Baru Lahir)",
        "vaksin": "Hepatitis B (HB-0), Polio 0",
        "manfaat": "Mencegah penularan Hepatitis B dari ibu ke bayi dan polio awal."
      },
      {
        "usia": "1 Bulan",
        "vaksin": "BCG",
        "manfaat": "Mencegah penyakit Tuberkulosis (TBC) berat."
      },
      {
        "usia": "2 Bulan",
        "vaksin": "DPT-HB-Hib 1, Polio 1, PCV 1, Rotavirus (RV) 1",
        "manfaat": "Mencegah difteri, pertusis, tetanus, pneumonia, dan diare berat."
      },
      {
        "usia": "3 Bulan",
        "vaksin": "DPT-HB-Hib 2, Polio 2, PCV 2, Rotavirus (RV) 2",
        "manfaat": "Dosis lanjutan untuk memperkuat antibodi si Kecil."
      },
      {
        "usia": "4 Bulan",
        "vaksin": "DPT-HB-Hib 3, Polio 3, Rotavirus (RV) 3",
        "manfaat": "Dosis lanjutan untuk perlindungan maksimal."
      },
      {
        "usia": "6 Bulan",
        "vaksin": "PCV 3, Polio 4, Influenza",
        "manfaat": "Dosis lanjutan PCV dan pencegahan virus flu."
      },
      {
        "usia": "9 Bulan",
        "vaksin": "MR (Campak-Rubella)",
        "manfaat": "Mencegah penyakit campak dan rubella yang berbahaya."
      },
      {
        "usia": "18 - 24 Bulan",
        "vaksin": "Booster DPT-HB-Hib, Booster MR",
        "manfaat": "Dosis penguat agar kekebalan tubuh bertahan lama."
      },
    ];

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: softPink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Jadwal Imunisasi",
          style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image / Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: navyDark,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.shield_rounded, size: 60, color: highlightPink),
                  const SizedBox(height: 15),
                  Text(
                    "Lindungi Si Kecil Sejak Dini!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pemberian imunisasi dasar lengkap sangat penting untuk membangun sistem kekebalan tubuh anak.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: softPink.withOpacity(0.8), fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // List Jadwal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Panduan Usia & Jenis Vaksin",
                style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              itemCount: jadwalImunisasi.length,
              itemBuilder: (context, index) {
                final item = jadwalImunisasi[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
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
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: navyDark,
                      collapsedIconColor: navyDark.withOpacity(0.7),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: Text(
                        item["usia"],
                        style: TextStyle(
                          color: navyDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        item["vaksin"],
                        style: TextStyle(
                          color: navyDark.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: navyDark.withOpacity(0.2)),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 18, color: navyDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item["manfaat"],
                                      style: TextStyle(
                                        color: navyDark.withOpacity(0.9),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}