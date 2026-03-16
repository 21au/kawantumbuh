import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'anak_screen.dart'; // File Anak Bunda yang baru
import 'tips_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Variabel penentu halaman mana yang aktif
  int _selectedIndex = 0;

  // Palette warna agar serasi dengan AnakScreen Bunda
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);

  // List halaman yang akan ditampilkan
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onNavigateToTips: () {
          setState(() {
            _selectedIndex = 2; // Sekarang Tips ada di Index 2
          });
        },
      ),
      const AnakScreen(),    // Index 1 (Kalkulator/Grafik Bunda)
      const TipsScreen(),    // Index 2
      const ProfileScreen(), // Index 3
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agar background warna halaman mengalir sampai ke bawah navbar
      extendBody: true, 
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // TOMBOL TENGAH (CHAT/ADD)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 65,
        width: 65,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFF5CBCB), // Mengikuti warna fieldPink Bunda
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () {
            // Aksi tombol tengah, misalnya buka konsultasi admin
          },
          child: Icon(Icons.chat_bubble_rounded, color: navyDark, size: 28),
        ),
      ),

      // NAVBAR MELENGKUNG (CUSTOM)
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: navyDark,
        shape: const CircularNotchedRectangle(), // Membuat lekukan
        notchMargin: 10, // Jarak lekukan dengan tombol
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sisi Kiri
            _buildNavItem(Icons.home_rounded, "Home", 0),
            _buildNavItem(Icons.calculate_outlined, "Anak", 1),
            
            // Ruang kosong untuk lekukan tombol tengah
            const SizedBox(width: 40),
            
            // Sisi Kanan
            _buildNavItem(Icons.bookmark_outline_rounded, "Tips", 2),
            _buildNavItem(Icons.person_outline_rounded, "Profil", 3),
          ],
        ),
      ),
    );
  }

  // Fungsi helper untuk membuat tombol navigasi agar kode rapi
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? softPink : Colors.white60,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? softPink : Colors.white60,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}