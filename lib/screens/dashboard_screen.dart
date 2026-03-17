import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:kawantumbuh/screens/statistik_pertumbuhan_screen.dart'; 
import 'anak_screen.dart'; 
import 'tips_screen.dart'; 
import 'detail_tips_screen.dart'; 
import 'jadwal_posyandu_screen.dart';

// --- TAMBAHAN IMPORT HALAMAN ARTIKEL BUNDA ---
import 'kia/makanan_terbaik_screen.dart';
import 'kia/imunisasi_screen.dart';
import 'kia/polaasuh_screen.dart';

class DashboardScreen extends StatefulWidget {
  // Callback untuk memberitahu Wrapper agar pindah ke Tab Tips
  final VoidCallback onNavigateToTips;

  const DashboardScreen({super.key, required this.onNavigateToTips});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- PALET WARNA UTAMA ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 
  final Color brightPink = Colors.pinkAccent; // Warna tambahan untuk notif

  String _userName = "Bunda"; 
  bool _isLoadingName = true;
  
  // --- STATE UNTUK DATA ANAK ---
  bool _isLoadingAnak = true;
  List<Map<String, dynamic>> _daftarAnak = [];
  int _selectedAnakIndex = 0;
  String _beratBadan = "-";
  String _tinggiBadan = "-";

  // --- FITUR BARU: STATE NOTIFIKASI BESOK ---
  bool _hasJadwalBesok = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchDataAnak(); 
  }

  // --- FUNGSI AMBIL NAMA BUNDA ---
  void _fetchUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final fullName = user.userMetadata?['full_name'] as String?;
      setState(() {
        _userName = fullName != null ? "Ibu $fullName" : "Ibu Pengguna";
        _isLoadingName = false;
      });
    }
  }

  // --- FUNGSI AMBIL DATA ANAK DARI SUPABASE ---
  Future<void> _fetchDataAnak() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final dataAnak = await Supabase.instance.client
          .from('anak')
          .select()
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _daftarAnak = List<Map<String, dynamic>>.from(dataAnak);
          _isLoadingAnak = false;
        });

        if (_daftarAnak.isNotEmpty) {
          final anakId = _daftarAnak[_selectedAnakIndex]['id'];
          _fetchRiwayatTerakhir(anakId);
          _cekJadwalBesok(anakId.toString()); // Cek jadwal setelah anak diload
        }
      }
    } catch (e) {
      debugPrint("Error fetch anak di dashboard: $e");
      if (mounted) setState(() => _isLoadingAnak = false);
    }
  }

  // --- FUNGSI BARU: CEK JADWAL AKTIF (HARI INI & MASA DEPAN) ---
  Future<void> _cekJadwalBesok(String anakId) async {
    try {
      // Ambil jam 00:00 hari ini biar akurat
      final now = DateTime.now();
      final hariIniString = DateTime(now.year, now.month, now.day).toIso8601String();

      // Cari jadwal yang tanggalnya >= hari ini DAN belum selesai
      final dataJadwal = await Supabase.instance.client
          .from('jadwal_posyandu')
          .select()
          .eq('anak_id', anakId)
          .eq('is_selesai', false)
          .gte('tanggal', hariIniString); // gte = Greater Than or Equal (Hari ini ke depan)

      if (mounted) {
        setState(() {
          // Kalau ada datanya, nyalakan titik merah!
          _hasJadwalBesok = dataJadwal.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Error cek jadwal aktif: $e");
    }
  }

  // --- FUNGSI AMBIL PENGUKURAN TERAKHIR ---
  Future<void> _fetchRiwayatTerakhir(dynamic anakId) async {
    try {
      final dataRiwayat = await Supabase.instance.client
          .from('pertumbuhan')
          .select()
          .eq('anak_id', anakId)
          .order('tanggal_pengukuran', ascending: false)
          .limit(1);

      if (mounted) {
        setState(() {
          if (dataRiwayat.isNotEmpty) {
            _beratBadan = "${dataRiwayat[0]['berat_badan']} kg";
            _tinggiBadan = "${dataRiwayat[0]['tinggi_badan']} cm";
          } else {
            _beratBadan = "- kg";
            _tinggiBadan = "- cm";
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetch riwayat terakhir: $e");
    }
  }

  // --- FUNGSI HITUNG UMUR (BULAN) ---
  String _hitungUsia(String? tglLahir) {
    if (tglLahir == null) return "- bulan";
    try {
      final birthDate = DateTime.parse(tglLahir);
      final today = DateTime.now();
      int months = (today.year - birthDate.year) * 12 + today.month - birthDate.month;
      if (today.day < birthDate.day) months--;
      return "$months bulan";
    } catch (e) {
      return "- bulan";
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return "${days[now.weekday]}, ${now.day} ${months[now.month]} ${now.year}";
  }

  // --- FUNGSI MUNCULKAN DROPDOWN PILIH ANAK ---
  void _tampilkanPilihAnak() {
    if (_daftarAnak.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: softPink,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: navyDark.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Text("Pilih Anak", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navyDark)),
              const SizedBox(height: 20),
              ...List.generate(_daftarAnak.length, (index) {
                final anak = _daftarAnak[index];
                final isSelected = index == _selectedAnakIndex;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? navyDark : highlightPink,
                    child: Icon(Icons.child_care, color: softPink),
                  ),
                  title: Text(anak['nama'] ?? "Anak", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: navyDark) : null,
                  onTap: () {
                    setState(() {
                      _selectedAnakIndex = index;
                      _beratBadan = "-"; 
                      _tinggiBadan = "-";
                      _hasJadwalBesok = false; // Reset notif saat ganti anak
                    });
                    _fetchRiwayatTerakhir(anak['id']);
                    _cekJadwalBesok(anak['id'].toString()); // Cek lagi jadwal untuk anak yang baru dipilih
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildMenuGrid(),
            const SizedBox(height: 25),
            _buildArticleSection(),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selamat Datang! 👋", style: TextStyle(color: softPink, fontSize: 16)),
                  const SizedBox(height: 4),
                  _isLoadingName 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: softPink, strokeWidth: 2))
                      : Text(_userName, style: TextStyle(color: softPink, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(_getFormattedDate(), style: TextStyle(color: softPink, fontSize: 13)),
                ],
              ),
              
              // --- UPGRADE: LONCENG DENGAN NOTIFIKASI DOT ---
              Container(
                decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_active_outlined, color: softPink),
                      onPressed: () {
                        if (_hasJadwalBesok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Bunda, ada jadwal Posyandu si Kecil yang menunggu nih! Yuk dicek kalendernya 💕"), 
                              backgroundColor: brightPink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Semua jadwal sudah beres! Belum ada notifikasi baru 😊"), 
                              backgroundColor: navyDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          );
                        }
                      },
                    ),
                    if (_hasJadwalBesok)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // KARTU ANAK 
          _buildKartuAnakDashboard(),
        ],
      ),
    );
  }

  // --- WIDGET KARTU ANAK ---
  Widget _buildKartuAnakDashboard() {
    if (_isLoadingAnak) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: softPink.withOpacity(0.50), borderRadius: BorderRadius.circular(25)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_daftarAnak.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AnakScreen())
          ).then((_) {
            setState(() {
              _isLoadingAnak = true;
            });
            _fetchDataAnak();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: softPink.withOpacity(0.50), borderRadius: BorderRadius.circular(25)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: highlightPink, radius: 28, child: Icon(Icons.add, color: softPink, size: 32)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Belum ada data anak", style: TextStyle(color: softPink, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Ketuk untuk menambahkan", style: TextStyle(color: softPink, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final anakAktif = _daftarAnak[_selectedAnakIndex];
    final umurBulan = _hitungUsia(anakAktif['tanggal_lahir']);

    return GestureDetector(
      onTap: _tampilkanPilihAnak, 
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: softPink.withOpacity(0.50), 
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: highlightPink,
              radius: 28,
              child: Icon(Icons.child_care, color: softPink, size: 32),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(anakAktif['nama'] ?? "Nama Anak", style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("$umurBulan · $_beratBadan · $_tinggiBadan", style: TextStyle(color: softPink, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: softPink, size: 28),
          ],
        ),
      ),
    );
  }

  // --- MENU GRID ---
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMenuCard(Icons.auto_graph_rounded, "Pertumbuhan", "Lihat\nGrafik"),
          _buildMenuCard(Icons.event_note_rounded, "Jadwal", "Janji\nTemu"),
          _buildMenuCard(Icons.tips_and_updates_rounded, "Tips Sehat", "Baca\nArtikel"),
        ],
      ),
    );
  }

  // --- FUNGSI KLIK MENU ---
  Widget _buildMenuCard(IconData icon, String title, String subtitle) {
    double width = (MediaQuery.of(context).size.width - 70) / 3;
    return GestureDetector(
      onTap: () async {
        if (title == "Tips Sehat") {
          widget.onNavigateToTips();
        } else if (title == "Pertumbuhan") {
          if (_daftarAnak.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Silakan tambah data anak terlebih dahulu", style: TextStyle(color: softPink)), backgroundColor: navyDark));
            return;
          }
          final anakAktif = _daftarAnak[_selectedAnakIndex];
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => StatistikPertumbuhanScreen(anakId: anakAktif['id'].toString(), namaAnak: anakAktif['nama'] ?? 'Si Kecil')
          )).then((_) {
            _cekJadwalBesok(anakAktif['id'].toString());
          });
        } else if (title == "Jadwal") {
          if (_daftarAnak.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Silakan tambah data anak terlebih dahulu", style: TextStyle(color: softPink)), backgroundColor: navyDark));
            return;
          }
          final anakAktif = _daftarAnak[_selectedAnakIndex];
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => JadwalPosyanduScreen(anakId: anakAktif['id'].toString(), namaAnak: anakAktif['nama'] ?? 'Si Kecil')
          )).then((_) {
            _cekJadwalBesok(anakAktif['id'].toString());
          });
        }
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: navyDark, 
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: navyDark.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: softPink, size: 30),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: softPink, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: softPink, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- ARTIKEL SECTION ---
  Widget _buildArticleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tips Kesehatan", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: widget.onNavigateToTips, 
                child: Text("Lihat Semua", style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          _buildArticleCard(
            itemData: {
              "category": "Nutrisi", 
              "title": "10 Makanan Terbaik Untuk Tumbuh Kembang Anak", 
              "desc": "Pastikan si kecil mendapatkan asupan nutrisi lengkap dari sayur dan protein hewani untuk mendukung pertumbuhan maksimalnya.", 
              "time": "5 mnt",
              "imageUrl": "assets/images/makanan.jpeg",
            },
          ),
          
         _buildArticleCard(
          itemData: {
            "category": "Kesehatan", 
            "title": "Jadwal Imunisasi Dasar Lengkap", 
            "desc": "Jangan sampai terlewat! Cek jadwal imunisasi dasar untuk melindungi si Kecil dari berbagai penyakit berbahaya sejak dini.", 
            "time": "10 mnt",
            "imageUrl": "assets/images/imunisasi.jpg", 
          },
        ),

        _buildArticleCard(
          itemData: {
            "category": "Pola Asuh", 
            "title": "Cara Mengatasi Tantrum pada Anak", 
            "desc": "Anak sering menangis berguling-guling? Tenang Bunda, berikut adalah langkah efektif untuk menghadapi tantrum.", 
            "time": "7 mnt",
            "imageUrl": "assets/images/polaasuh.jpeg", 
          },
        ),
        ],
      ),
    );
  }

  // --- UPDATE PENTING: MENGARAHKAN KE SCREEN YANG BENAR ---
  Widget _buildArticleCard({required Map<String, String> itemData}) {
    final String imageUrl = itemData['imageUrl'] ?? '';
    final bool isNetworkImage = imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        // Cek judul artikel untuk menentukan halaman yang dibuka
        if (itemData['title'] == "10 Makanan Terbaik Untuk Tumbuh Kembang Anak") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MakananTerbaikScreen()));
        } else if (itemData['title'] == "Jadwal Imunisasi Dasar Lengkap") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ImunisasiScreen()));
        } else if (itemData['category'] == "Pola Asuh") {
          // Buka PolaAsuhScreen yang baru dibuat
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PolaAsuhScreen()));
        } else {
          // Default: Buka halaman detail bawaan jika artikel belum ada screen khususnya
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTipsScreen(item: itemData)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: fieldPink,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: isNetworkImage
                  ? Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                    )
                  : Image.asset(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemData['title']!,
                      style: TextStyle(
                          color: navyDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(itemData['desc']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: navyDark.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi tambahan untuk tampilan kalau gambar gagal loading
  Widget _buildErrorPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: highlightPink,
      child: Icon(Icons.broken_image, color: softPink, size: 40),
    );
  }
}