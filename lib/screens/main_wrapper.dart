import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'anak_screen.dart';
import 'tips_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardScreen(),
    const AnakScreen(),
    const TipsScreen(),
    const ProfileScreen(),
  ];

  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color highlightText = const Color(0xFFF69C91);
  final Color fabColor = const Color.fromARGB(255, 255, 203, 203);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true membuat body aplikasi memanjang ke bawah Navbar.
      // Ini kunci untuk menghilangkan background putih di belakang notch.
      extendBody: true,
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Tombol Chat melayang
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi Chat Konsultasi
        },
        backgroundColor: fabColor,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(Icons.chat_bubble_outline, color: navyBackground, size: 28),
      ),
      
      // Mengatur posisi FAB tepat di tengah lekukan Navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: navyBackground,
      // clipBehavior: Clip.antiAlias menghaluskan potongan lekukan
      clipBehavior: Clip.antiAlias,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sisi Kiri (Home & Anak)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
                  _buildNavItem(Icons.child_care, Icons.child_care, "Anak", 1),
                ],
              ),
            ),
            
            // Memberi ruang kosong tepat di tengah untuk notch FAB
            const SizedBox(width: 48), 

            // Sisi Kanan (Tips & Profil)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.lightbulb_outline, Icons.lightbulb, "Tips", 2),
                  _buildNavItem(Icons.person_outline, Icons.person, "Profil", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData inactiveIcon, IconData activeIcon, String label, int index) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? highlightText : Colors.white54,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isActive ? highlightText : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}