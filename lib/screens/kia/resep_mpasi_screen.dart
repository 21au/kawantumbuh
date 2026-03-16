import 'package:flutter/material.dart';

class ResepMpasiScreen extends StatelessWidget {
  const ResepMpasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    // --- DATA ATURAN DASAR MPASI 6 BULAN ---
    final List<Map<String, String>> aturanDasar = [
      {
        "judul": "Tekstur (Puree & Saring)",
        "isi": "Makanan harus dilumatkan hingga sangat halus (blender lalu saring kawat) agar bayi tidak tersedak. Kekentalannya pas jika sendok dimiringkan, makanan tidak langsung tumpah.",
        "ikon": "🥣"
      },
      {
        "judul": "Porsi Makan",
        "isi": "Mulai dengan 2-3 sendok makan dalam sekali makan. Berikan 2 kali sehari (bisa ditambah 1-2 kali camilan buah puree jika anak mau).",
        "ikon": "🥄"
      },
      {
        "judul": "Komposisi Menu Lengkap",
        "isi": "Pastikan ada Karbohidrat (nasi/kentang), Protein Hewani (ayam/ikan/telur) yang sangat penting untuk cegah stunting, Sayur/Buah secukupnya, dan Lemak Tambahan (minyak/mentega/santan).",
        "ikon": "🥩"
      },
    ];

    // --- DATA RESEP PILIHAN ---
    final List<Map<String, dynamic>> resepPilihan = [
      {
        "nama": "1. Bubur Nasi Ayam Brokoli",
        "bahan": "• 1 sdm nasi lembek\n• 50 gr dada ayam kampung\n• 1 kotak kecil tahu\n• 1 kuntum brokoli\n• 1 sdt minyak zaitun/mentega",
        "cara": "Kukus ayam, tahu, dan brokoli hingga sangat empuk. Blender semua bahan dengan nasi dan sedikit air/kaldu. Saring dengan saringan kawat, tambahkan minyak zaitun sebelum disajikan."
      },
      {
        "nama": "2. Puree Telur Rebus & Keju",
        "bahan": "• 1 butir telur ayam / 3 telur puyuh\n• 1 sdm keju parut (belcube/cheddar)\n• Sedikit air matang / ASI / Sufor",
        "cara": "Rebus telur hingga benar-benar matang sempurna (jangan setengah matang). Blender telur rebus bersama keju dan air matang hingga lembut. Saring agar tidak ada gumpalan kuning telur yang bikin seret."
      },
      {
        "nama": "3. Puree Kentang Salmon",
        "bahan": "• 1/2 buah kentang kecil\n• 50 gr fillet salmon\n• 1 sdt minyak goreng/zaitun\n• Sedikit daun jeruk (penghilang amis)",
        "cara": "Kupas dan rebus kentang hingga empuk. Panaskan minyak, tumis salmon dengan daun jeruk hingga matang. Buang daun jeruk, blender kentang dan salmon dengan sedikit air. Saring hingga halus."
      },
    ];

    // --- DATA PANTANGAN ---
    final List<String> pantangan = [
      "Madu (sangat dilarang di bawah usia 1 tahun karena risiko bakteri botulisme).",
      "Gula dan Garam (hindari atau berikan seminimal mungkin, lebih baik gunakan kaldu alami).",
      "Susu Sapi Segar / UHT (hanya boleh digunakan sedikit sebagai bahan campuran masakan, bukan sebagai minuman pengganti ASI/Sufor).",
      "Makanan bertekstur keras atau bulat utuh seperti anggur utuh atau kacang (risiko tersedak).",
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
        title: Text("Resep MPASI 6 Bulan", style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR HEADER DARI UNSPLASH ---
            Image.asset(
              "assets/images/mpasi.jpeg",
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220, width: double.infinity, color: highlightPink,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_rounded, color: softPink, size: 40),
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
                    "Selamat Datang di Fase MPASI!",
                    style: TextStyle(color: navyDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Di usia 6 bulan, ASI saja sudah tidak cukup untuk memenuhi kebutuhan nutrisi harian (terutama Zat Besi). Mari mulai petualangan rasa si Kecil dengan menu homemade bergizi tinggi!",
                    style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // --- 1. SECTION ATURAN DASAR ---
                  _buildSectionHeader(Icons.info_outline_rounded, "Aturan Dasar 6 Bulan", navyDark),
                  const SizedBox(height: 15),
                  ...aturanDasar.map((item) => Container(
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
                        Text(item["ikon"]!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["judul"]!, style: TextStyle(color: navyDark, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(item["isi"]!, style: TextStyle(color: navyDark.withOpacity(0.9), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 25),

                  // --- 2. SECTION RESEP PILIHAN ---
                  _buildSectionHeader(Icons.blender_rounded, "3 Ide Resep Lengkap", navyDark),
                  const SizedBox(height: 15),
                  ...resepPilihan.map((resep) => Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: fieldPink,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ExpansionTile(
                      iconColor: navyDark,
                      collapsedIconColor: navyDark.withOpacity(0.6),
                      title: Text(resep["nama"], style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 15)),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bahan-bahan:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(resep["bahan"], style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13, height: 1.4)),
                              const SizedBox(height: 15),
                              Text("Cara Membuat:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(resep["cara"], style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13, height: 1.4)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  const SizedBox(height: 25),

                  // --- 3. SECTION PANTANGAN (WARNING BOX) ---
                  _buildSectionHeader(Icons.do_not_disturb_alt_rounded, "Pantangan & Bahaya", const Color(0xFFD32F2F)),
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
                        Text("Jauhkan bahan-bahan berikut dari menu MPASI bayi di bawah 1 tahun:", 
                          style: TextStyle(color: const Color(0xFFC62828), fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 12),
                        ...pantangan.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("❌ ", style: TextStyle(fontSize: 14)),
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
                        Icon(Icons.menu_book_rounded, color: navyDark, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Referensi Resep & Nutrisi:", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Panduan MPASI 6 Bulan - HaiBunda", style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
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