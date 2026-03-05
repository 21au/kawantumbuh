import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib ditambahkan
import 'package:kawantumbuh/screens/statistik_pertumbuhan_screen.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'anak_screen.dart'; 
import 'tips_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color menuCardBlue = const Color(0xFF1E88B3);
  final Color highlightText = const Color(0xFFF69C91);
  final Color childCardColor = const Color(0xFFB88E9B);
  final Color articleCardColor = const Color(0xFFEAA6A9);

  // 1. Siapkan variabel untuk menyimpan nama pengguna
  String _userName = "Bunda"; 
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Panggil fungsi ambil nama saat layar dibuka
  }

  // 2. Fungsi untuk mengambil nama dari Supabase
  void _fetchUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Ambil data 'full_name' dari user_metadata yang kita simpan pas register
      final fullName = user.userMetadata?['full_name'] as String?;
      if (fullName != null && fullName.isNotEmpty) {
        setState(() {
          // Kita tambahkan kata sapaan "Ibu " atau "Bunda " di depannya
          _userName = "Ibu $fullName";
          _isLoadingName = false;
        });
      } else {
        setState(() {
          _userName = "Ibu Pengguna"; // Jaga-jaga kalau namanya kosong
          _isLoadingName = false;
        });
      }
    }
  }

  // Fungsi tambahan untuk memformat tanggal hari ini
  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = [
      '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return "${days[now.weekday]}, ${now.day} ${months[now.month]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMenuGrid(),
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: navyBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat Datang! 👋", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  // 3. Tampilkan nama yang sudah diambil dari database
                  _isLoadingName 
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(_userName, style: TextStyle(color: highlightText, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // Tanggal juga saya buat otomatis berubah sesuai hari ini
                  Text(_getFormattedDate(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: childCardColor.withOpacity(0.5), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnakScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: childCardColor, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 24,
                    child: Icon(Icons.child_care, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fatimah Azzahra", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("18 bulan · 10 kg · 80 cm", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU GRID & ARTICLE ---
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        children: [
          _buildMenuCard(Icons.trending_up, "Pertumbuhan", "Lihat Grafik\nPertumbuhan"),
          _buildMenuCard(Icons.calendar_month, "Jadwal", "Buat Janji\nTemu"),
          _buildMenuCard(Icons.lightbulb_outline, "Tips Sehat", "Baca Artikel\nKesehatan"),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String subtitle) {
    double width = (MediaQuery.of(context).size.width - 55) / 2;
    return GestureDetector(
      onTap: () {
        if (title == "Tips Sehat") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen()));
        } else if (title == "Pertumbuhan") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikPertumbuhanScreen()));
        }
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: menuCardBlue, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: highlightText.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: highlightText, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title, style: TextStyle(color: highlightText, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tips Kesehatan", style: TextStyle(color: navyBackground, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen())),
                child: Text("Lihat Semua", style: TextStyle(color: navyBackground.withOpacity(0.6), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildArticleCard(),
        ],
      ),
    );
  }

  Widget _buildArticleCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: articleCardColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.network(
                "https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80",
                height: 140, width: double.infinity, fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("10 Makanan Terbaik Untuk Tumbuh Kembang Anak", 
                    style: TextStyle(color: navyBackground, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("Pastikan si kecil mendapatkan asupan nutrisi lengkap...", 
                    style: TextStyle(color: navyBackground.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}