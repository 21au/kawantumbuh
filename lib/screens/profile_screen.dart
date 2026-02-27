import 'package:flutter/material.dart';
import 'package:kawantumbuh/utils/app_colors.dart';
import 'edit_profile_screen.dart'; 
import 'daftar_anak_screen.dart'; // Jangan lupa import ini

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Simulasi data dari Database
  final String namaUser = "Bunda Sarah";
  final String nomorTelepon = "0812-3456-7890";

  final Color navyBackground = const Color(0xFF1A2B4C);
  final Color oceanBlue = const Color(0xFF1E88B3);
  final Color offWhitePink = const Color(0xFFFCE8E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfileMenu(context),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 120), 
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: navyBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: offWhitePink,
                child: Icon(Icons.person, size: 60, color: navyBackground),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: oceanBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            namaUser,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            nomorTelepon,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pengaturan Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))),
          const SizedBox(height: 15),
          
          // Menu Edit Profil
          _buildMenuItem(Icons.person_outline, "Edit Profil", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }),
          
          // Menu Daftar Anak (Sudah diperbaiki)
          _buildMenuItem(Icons.child_care, "Daftar Anak", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnakScreen()));
          }),
          
          _buildMenuItem(Icons.notifications_none, "Notifikasi", () {}),
          const SizedBox(height: 25),
          const Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))),
          const SizedBox(height: 15),
          _buildMenuItem(Icons.help_outline, "Pusat Bantuan", () {}),
          _buildMenuItem(Icons.privacy_tip_outlined, "Kebijakan Privasi", () {}),
          _buildMenuItem(Icons.info_outline, "Tentang Aplikasi", () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: offWhitePink, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: oceanBlue),
        title: Text(title, style: TextStyle(color: navyBackground, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Akun?"),
        content: const Text("Apakah Bunda yakin ingin keluar dari aplikasi KawanTumbuh?"),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              // Di sini nanti tempat menghapus token/session backend
              Navigator.pop(context); // Tutup dialog
              // Navigator.pushAndRemoveUntil(...) ke halaman Login
              print("User Logout"); 
            },
          ),
        ],
      );
    },
  );
},
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}