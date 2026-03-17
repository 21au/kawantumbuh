import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Jangan lupa: flutter pub add url_launcher
import 'dashboard_screen.dart'; 
import 'anak_screen.dart';      
import 'tips_screen.dart';      
import 'profile_screen.dart';   

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

// TAMBAHAN: Kita tambahkan SingleTickerProviderStateMixin untuk mengaktifkan animasi
class _MainWrapperState extends State<MainWrapper> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Warna sesuai palet aplikasi Bunda
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color fieldPink = const Color(0xFFF5CBCB);

  late final List<Widget> _screens;
  
  // --- STATE UNTUK ANIMASI HALAMAN ---
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller animasi halaman dengan durasi 300 ms
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Jalankan animasi untuk pertama kali
    _fadeController.forward();

    _screens = [
      DashboardScreen(
        onNavigateToTips: () {
          // Panggil _onItemTapped agar saat pindah ke menu Tips dari Dashboard, animasinya tetap jalan
          _onItemTapped(2); 
        },
      ),
      const AnakScreen(),
      const TipsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose(); // Wajib dihapus agar memori tidak bocor
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Putar ulang animasi fade-in dari awal setiap kali pindah tab
      _fadeController.forward(from: 0.0);
    }
  }

  // --- FUNGSI BUKA WHATSAPP ---
  Future<void> _launchWhatsApp() async {
    // TODO: Ganti nomor WA Admin/Bidan di sini (Pakai awalan 62, TANPA + atau 0)
    const String nomorWA = "6281234567890"; 
    const String pesan = "Halo Bidan / Admin Kawan Tumbuh, saya ingin berkonsultasi mengenai anak saya...";
    
    final Uri waUrl = Uri.parse("https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesan)}");

    try {
      if (!await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka WhatsApp. Pastikan aplikasi ter-install ya, Bun.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      
      // --- PERBAIKAN: Bungkus IndexedStack dengan FadeTransition ---
      body: FadeTransition(
        opacity: _fadeController,
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      
      // --- TOMBOL TENGAH (CHAT WA) ---
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: fieldPink,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(Icons.chat_bubble_outline_rounded, color: navyDark, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- NAVBAR MELENGKUNG (NOTCHED) ---
      bottomNavigationBar: BottomAppBar(
        color: navyDark,
        shape: const CircularNotchedRectangle(), 
        notchMargin: 8.0, 
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 70, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kelompok Menu Kiri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabItem(icon: Icons.home_rounded, label: "Home", index: 0),
                  _buildTabItem(icon: Icons.child_care_rounded, label: "Anak", index: 1), 
                ],
              ),
              
              // Kelompok Menu Kanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabItem(icon: Icons.bookmark_border_rounded, label: "Tips", index: 2),
                  _buildTabItem(icon: Icons.person_outline_rounded, label: "Profil", index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK IKON NAVBAR ---
  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? softPink : softPink.withOpacity(0.5);

    return MaterialButton(
      minWidth: 75,
      splashColor: Colors.transparent, // Menghilangkan bayangan lingkaran abu-abu bawaan biar lebih clean
      highlightColor: Colors.transparent,
      onPressed: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- PERBAIKAN: Animasi pembesaran ukuran ikon yang mulus (Bouncy Effect) ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack, // Efek membal saat aktif
            transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
            transformAlignment: Alignment.center,
            child: Icon(
              icon,
              color: color,
              size: 24, // Base sizenya 24, kalau aktif dia dikalikan 1.2 dari fungsi scale
            ),
          ),
          const SizedBox(height: 4),
          // --- PERBAIKAN: Animasi perubahan warna dan ketebalan teks ---
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}