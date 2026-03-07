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

  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);
  final Color softPink = const Color(0xFFFFEAEA);
  final Color highlightPink = const Color(0xFFEBA9A9);

  // Fungsi untuk berpindah tab yang bisa dipanggil dari child widget
  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman diletakkan di dalam build agar bisa mengirimkan fungsi _navigateToTab
    final List<Widget> pages = [
      DashboardScreen(
        onNavigateToTips: () => _navigateToTab(2), // Index 2 adalah TipsScreen
      ),
      const AnakScreen(),
      const TipsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, 
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      // --- TOMBOL CHAT MELAYANG (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi Chat Konsultasi
        },
        backgroundColor: highlightPink,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(Icons.chat_bubble_rounded, color: navyDark, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: navyDark,
      clipBehavior: Clip.antiAlias,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 0,
      child: SizedBox(
        height: 65, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
                  _buildNavItem(Icons.child_care_outlined, Icons.child_care, "Anak", 1),
                ],
              ),
            ),
            
            const SizedBox(width: 48), 

            Expanded(
              child: Row(
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

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, 
        onTap: () => _navigateToTab(index), // Menggunakan fungsi helper
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack, 
          transform: Matrix4.translationValues(0, isActive ? -6 : 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  key: ValueKey<bool>(isActive), 
                  color: isActive ? highlightPink : softPink, 
                  size: isActive ? 28 : 24, 
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive ? highlightPink : softPink, 
                  fontSize: isActive ? 11 : 10, 
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}