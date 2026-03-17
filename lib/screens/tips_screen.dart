import 'package:flutter/material.dart';
import 'package:kawantumbuh/screens/kia/polaasuh_screen.dart';

// --- IMPORT HALAMAN ARTIKEL YANG SUDAH DIBUAT ---
import 'kia/nutrisi_screen.dart';
import 'kia/imunisasi_screen.dart';
import 'kia/makanan_terbaik_screen.dart'; 
import 'kia/tidur_screen.dart'; 
import 'kia/mainan_edukasi_screen.dart'; 
import 'kia/mandi_screen.dart'; 
import 'kia/tantrum_screen.dart'; 
import 'kia/pertolongan_demam_screen.dart'; 
import 'kia/resep_mpasi_screen.dart'; 
import 'kia/keterlambatan_bicara_screen.dart';
import 'kia/merawat_gigi_susu_screen.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  // --- PALET WARNA UTAMA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA); 
  final Color fieldPink = const Color(0xFFF5CBCB); 
  final Color highlightPink = const Color(0xFFEBA9A9); 

  // --- DATA TIPS (DATA ASLI) ---
  final List<Map<String, dynamic>> daftarTips = [
    {
      "category": "Nutrisi", 
      "title": "10 Makanan Terbaik", 
      "desc": "Nutrisi lengkap untuk anak.", 
      "time": "5 mnt",
      "imageUrl": "assets/images/makanan.jpeg",
      "targetScreen": const MakananTerbaikScreen(), 
    },
    {
      "category": "Kesehatan", 
      "title": "Jadwal Imunisasi", 
      "desc": "Kekebalan tubuh anak.", 
      "time": "10 mnt",
      "imageUrl": "assets/images/imunisasi.jpg", 
      "targetScreen": const ImunisasiScreen(), 
    },
    {
      "category": "Perawatan", 
      "title": "Kualitas Tidur Bayi", 
      "desc": "Penting bagi otak bayi.", 
      "time": "8 mnt",
      "imageUrl": "assets/images/tidur.jpeg", 
      "targetScreen": const TidurScreen(), 
    },
    {
      "category": "Stimulasi", 
      "title": "Mainan Edukasi", 
      "desc": "Rangsang motorik halus.", 
      "time": "6 mnt",
      "imageUrl": "assets/images/mainan.png", 
      "targetScreen": const MainanEdukasiScreen(), 
    },
    {
      "category": "Tips", 
      "title": "Cara Mandi Bayi", 
      "desc": "Panduan aman mandi bayi.", 
      "time": "5 mnt",
      "imageUrl": "assets/images/mandi.png", 
      "targetScreen": const MandiScreen(), 
    },
    {
      "category": "Psikologi", 
      "title": "Mengatasi Anak Tantrum", 
      "desc": "Cara tenang menghadapi ledakan emosi.", 
      "time": "7 mnt",
      "imageUrl": "assets/images/tantrum.jpeg", 
      "targetScreen": const TantrumScreen(), 
    },
    {
      "category": "Kesehatan", 
      "title": "Pertolongan Pertama Demam", 
      "desc": "Langkah awal saat suhu anak naik.", 
      "time": "6 mnt",
      "imageUrl": "assets/images/demam.jpg", 
      "targetScreen": const PertolonganDemamScreen(), 
    },
    {
      "category": "Gizi", 
      "title": "Ide Resep MPASI 6 Bulan", 
      "desc": "Menu lezat dan bergizi untuk pemula.", 
      "time": "8 mnt",
      "imageUrl": "assets/images/mpasi.jpeg", 
      "targetScreen": const ResepMpasiScreen(), 
    },
    {
      "category": "Perkembangan", 
      "title": "Tanda Bahaya Keterlambatan Bicara", 
      "desc": "Kapan harus ke dokter tumbuh kembang?", 
      "time": "10 mnt",
      "imageUrl": "https://images.unsplash.com/photo-1544126592-807ade215a0b?w=200", 
      "targetScreen": const KeterlambatanBicaraScreen(), 
    },
    {
      "category": "Gigi & Mulut", 
      "title": "Merawat Gigi Susu Sejak Dini", 
      "desc": "Cegah karies gigi sebelum terlambat.", 
      "time": "5 mnt",
      "imageUrl": "https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=200", 
      "targetScreen": const MerawatGigiSusuScreen(), 
    },
    {
      "category": "Pola Asuh Anak Yang Baik", 
      "title": "Apa itu pola asuh anak?", 
      "desc": "Cara mendidik anak dengan pola asuh yang tepat.", 
      "time": "5 mnt",
      "imageUrl": "assets/images/polaasuh.jpeg", 
      "targetScreen": const PolaAsuhScreen(), 
    },
  ];

  // --- LIST YANG AKAN DITAMPILKAN & DIFILTER ---
  List<Map<String, dynamic>> foundTips = [];

  @override
  void initState() {
    super.initState();
    // Saat layar pertama dibuka, tampilkan semua artikel
    foundTips = daftarTips;
  }

  // --- FUNGSI PENCARIAN ---
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // Jika kotak pencarian kosong, tampilkan semua
      results = daftarTips;
    } else {
      // Filter berdasarkan judul atau kategori (huruf besar/kecil diabaikan)
      results = daftarTips
          .where((tip) =>
              tip["title"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              tip["category"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh layar dengan data hasil pencarian
    setState(() {
      foundTips = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink, 
      appBar: AppBar(
        backgroundColor: navyDark, 
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Tips Kesehatan", 
          style: TextStyle(color: softPink, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- SEKSI CARI ARTIKEL ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            color: navyDark, 
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: softPink, 
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onChanged: (value) => _runFilter(value), // <-- Panggil fungsi pencarian saat mengetik
                style: TextStyle(color: navyDark), 
                decoration: InputDecoration(
                  hintText: "Cari artikel kesehatan...",
                  hintStyle: TextStyle(color: navyDark.withOpacity(0.5), fontSize: 16),
                  icon: Icon(Icons.search, color: navyDark.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // --- LIST ARTIKEL ---
          Expanded(
            child: foundTips.isEmpty
                ? Center(
                    // Jika artikel tidak ditemukan
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 60, color: highlightPink),
                        const SizedBox(height: 10),
                        Text("Artikel tidak ditemukan", 
                          style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 100), // Padding bawah agar tidak ketutupan navbar
                    itemCount: foundTips.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = foundTips[index];
                      
                      // Cek apakah gambar dari asset atau internet
                      final bool isAsset = item['imageUrl'].toString().startsWith('assets/');

                      return Card(
                        color: fieldPink, 
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shadowColor: navyDark.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: isAsset
                                ? Image.asset(
                                    item['imageUrl'] as String,
                                    width: 60, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(highlightPink, softPink),
                                  )
                                : Image.network(
                                    item['imageUrl'] as String,
                                    width: 60, height: 60, fit: BoxFit.cover, cacheWidth: 120, 
                                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(highlightPink, softPink),
                                  ),
                          ),
                          title: Text(
                            item['title'] as String, 
                            style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item['desc'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, 
                                style: TextStyle(color: navyDark.withOpacity(0.7), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(item['category'] as String, 
                                style: TextStyle(color: navyDark, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 12, color: navyDark.withOpacity(0.5)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => item['targetScreen'] as Widget));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk menangani gambar yang gagal dimuat
  Widget _buildErrorImage(Color bgColor, Color iconColor) {
    return Container(
      width: 60, height: 60, color: bgColor,
      child: Icon(Icons.image_not_supported_rounded, color: iconColor),
    );
  }
}