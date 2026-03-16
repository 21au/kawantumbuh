import 'package:flutter/material.dart';

class PertolonganDemamScreen extends StatelessWidget {
  const PertolonganDemamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA PERTOLONGAN PERTAMA (Referensi Halodoc) ---
    final List<Map<String, String>> langkahPertolongan = [
      {
        "langkah": "1. Penuhi Kebutuhan Cairan",
        "penjelasan": "Anak yang demam sangat rentan mengalami dehidrasi. Berikan lebih banyak ASI, susu, air putih, atau kuah sup hangat agar tubuhnya tetap terhidrasi dengan baik.",
        "ikon": "💧"
      },
      {
        "langkah": "2. Kenakan Pakaian Tipis",
        "penjelasan": "Jangan memakaikan jaket atau selimut tebal saat anak demam, karena justru akan mengurung panas. Pakaikan baju berbahan katun tipis yang menyerap keringat.",
        "ikon": "👕"
      },
      {
        "langkah": "3. Kompres Air Hangat",
        "penjelasan": "Gunakan kain yang dibasahi air hangat (bukan air dingin atau alkohol) lalu letakkan di area lipatan seperti ketiak dan selangkangan selama 10-15 menit untuk bantu keluarkan panas.",
        "ikon": "🌡️"
      },
      {
        "langkah": "4. Atur Suhu Ruangan",
        "penjelasan": "Pastikan kamar anak memiliki sirkulasi udara yang baik. Atur suhu ruangan agar tetap sejuk dan nyaman, tidak terlalu panas dan tidak terlalu dingin.",
        "ikon": "🌬️"
      },
      {
        "langkah": "5. Berikan Obat Penurun Panas",
        "penjelasan": "Jika anak tampak rewel atau kesakitan, berikan obat penurun panas seperti Paracetamol atau Ibuprofen sesuai dosis. (Catatan: Hindari penggunaan Aspirin pada anak).",
        "ikon": "💊"
      },
    ];

    // --- DATA TANDA BAHAYA ---
    final List<String> tandaBahaya = [
      "Suhu tubuh mencapai 39°C atau lebih.",
      "Demam berlangsung lebih dari 3 hari (72 jam).",
      "Anak mengalami kejang demam.",
      "Anak menolak minum, menangis tanpa air mata, atau jarang buang air kecil (tanda dehidrasi berat).",
      "Disertai muntah terus-menerus, diare, ruam, atau sesak napas.",
      "Anak tampak sangat lemas, mengantuk terus, dan sulit dibangunkan.",
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
        title: Text("Pertolongan Demam", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER DARI UNSPLASH ---
            Image.asset(
              "assets/images/demam.jpg",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220, width: double.infinity, color: highlightPink,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: softPink, size: 40),
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
                    "Jangan Panik Saat Si Kecil Demam",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Demam sebenarnya bukanlah sebuah penyakit, melainkan respons alami sistem kekebalan tubuh yang sedang melawan infeksi virus atau bakteri. Ibu tidak perlu buru-buru ke rumah sakit jika kondisinya masih bisa ditangani di rumah.",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION LANGKAH PERTOLONGAN ---
                  _buildSectionHeader(Icons.medical_services_rounded, "5 Langkah Pertolongan Pertama", navyDark),
                  const SizedBox(height: 15),
                  ...langkahPertolongan.map((item) => Container(
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
                              Text(item["langkah"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(item["penjelasan"]!, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 25),

                  // --- 2. SECTION TANDA BAHAYA (WARNING BOX) ---
                  _buildSectionHeader(Icons.warning_rounded, "Kapan Harus ke Dokter?", const Color(0xFFD32F2F)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE), // Warna merah muda peringatan
                      border: Border.all(color: const Color(0xFFEF5350), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Segera bawa si Kecil ke rumah sakit atau dokter anak jika muncul tanda bahaya berikut:", 
                          style: TextStyle(color: const Color(0xFFC62828), fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 12),
                        ...tandaBahaya.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("🚨 ", style: TextStyle(fontSize: 14)),
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
                        Icon(Icons.local_hospital_rounded, color: navyDark, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ditinjau Berdasarkan:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Artikel Medis Halodoc\n(5 Pertolongan Pertama pada Anak Demam)", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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