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
  int _selectedIndex = 0;
  final Color navyDark = const Color(0xFF102C57);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onNavigateToTips: () {
          setState(() => _selectedIndex = 2);
        },
      ),
      const AnakScreen(),
      const TipsScreen(),
      const ProfileScreen(),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: navyDark.withOpacity(0.1), 
              blurRadius: 20, 
              offset: const Offset(0, -5)
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: navyDark,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), 
              label: 'Beranda'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.child_friendly_rounded), 
              label: 'Anak'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_rounded), 
              label: 'Tips'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), 
              label: 'Profil'
            ),
          ],
        ),
      ),
    );
  }
}