import 'package:flutter/material.dart';
import '../detail_tips_screen.dart'; // Import template detail yang tadi
import 'data_edukasi.dart'; // Import bank data KIA

class InfoKIAScreen extends StatelessWidget {
  const InfoKIAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA (Konsisten dengan TipsScreen) ---
    final Color navyDark = const Color(0xFF102C57);
    final Color softPink = const Color(0xFFFFEAEA);
    final Color fieldPink = const Color(0xFFF5CBCB);
    final Color highlightPink = const Color(0xFFEBA9A9);

    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: navyDark,
        elevation: 0,
        title: Text(
          "Informasi Buku KIA",
          style: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: softPink),
      ),
      body: Column(
        children: [
          // Header Informatif
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: navyDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo Bunda!",
                  style: TextStyle(color: highlightPink, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Pantau tumbuh kembang si kecil sesuai standar Kemenkes RI melalui info di bawah ini.",
                  style: TextStyle(color: softPink.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),

          // Menu Utama KIA dalam bentuk Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom sampingan
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85, // Mengatur tinggi kotak
              ),
              itemCount: DataEdukasi.infoKIA.length,
              itemBuilder: (context, index) {
                final item = DataEdukasi.infoKIA[index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTipsScreen(item: item),
                      ),
                    );
                  },
                  child: Container(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Bulat
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: navyDark.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(item['title']), // Fungsi pilih icon di bawah
                            color: navyDark,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Judul
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            item['title'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: navyDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Label Waktu Baca
                        Text(
                          item['time'] ?? '',
                          style: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Catatan Tambahan di bawah
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "*Sumber: Buku KIA Kemenkes RI",
              style: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  // Fungsi sederhana untuk memilih icon berdasarkan judul
  IconData _getIconData(String? title) {
    if (title == null) return Icons.book;
    if (title.contains("Imunisasi")) return Icons.vaccines;
    if (title.contains("KMS")) return Icons.bar_chart;
    if (title.contains("Menyusui")) return Icons.child_care;
    return Icons.menu_book;
  }
}