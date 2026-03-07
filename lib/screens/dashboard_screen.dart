import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kawantumbuh/screens/statistik_pertumbuhan_screen.dart';
import 'anak_screen.dart'; 
import 'tips_screen.dart'; 
import 'detail_tips_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  // Callback untuk memberitahu Wrapper agar pindah ke Tab Tips
  final VoidCallback onNavigateToTips;

  const DashboardScreen({super.key, required this.onNavigateToTips});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- 4 PALET WARNA UTAMA BUNDA (100% TANPA HITAM) ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 

  String _userName = "Bunda"; 
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

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

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return "${days[now.weekday]}, ${now.day} ${months[now.month]} ${now.year}";
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
              Container(
                decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.notifications_active_outlined, color: softPink),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnakScreen())),
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
                        Text("Fatimah Azzahra", style: TextStyle(color: softPink, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("18 bulan · 10 kg · 80 cm", style: TextStyle(color: softPink, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: softPink, size: 20),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildMenuCard(IconData icon, String title, String subtitle) {
    double width = (MediaQuery.of(context).size.width - 70) / 3;
    return GestureDetector(
      onTap: () {
        // Pindah tab via Wrapper kalau Tips dipencet
        if (title == "Tips Sehat") {
          widget.onNavigateToTips();
        } else if (title == "Pertumbuhan") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikPertumbuhanScreen()));
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
                onTap: widget.onNavigateToTips, // Langsung panggil fungsi navigasi tab
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
              "imageUrl": "https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80"
            },
          ),
          
          _buildArticleCard(
            itemData: {
              "category": "Perawatan", 
              "title": "Pentingnya Jam Tidur Ideal Bagi Balita", 
              "desc": "Tidur yang cukup sangat berpengaruh pada perkembangan kecerdasan otak si kecil serta menjaga mood-nya sepanjang hari.", 
              "time": "8 mnt",
              "imageUrl": "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=800&q=80"
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({required Map<String, String> itemData}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTipsScreen(item: itemData))),
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
              child: Image.network(
                itemData['imageUrl']!,
                height: 150, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150, width: double.infinity, color: highlightPink,
                  child: Icon(Icons.image, color: softPink, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemData['title']!, style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(itemData['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: navyDark.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}