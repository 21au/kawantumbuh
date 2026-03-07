import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edit_profile_screen.dart'; 
import 'daftar_anak_screen.dart'; 
import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- PALET WARNA UTAMA BUNDA ---
  final Color navyDark = const Color(0xFF102C57);      
  final Color softPink = const Color(0xFFFFEAEA);      
  final Color fieldPink = const Color(0xFFF5CBCB);     
  final Color highlightPink = const Color(0xFFEBA9A9); 

  String namaUser = "Bunda";
  String nomorTelepon = "";
  String? avatarUrl; 
  bool _isUploading = false; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        setState(() {
          nomorTelepon = (user.email?.replaceAll('@kawantumbuh.com', '') ?? '-').toString();
          if (data != null) {
            namaUser = (data['full_name'] ?? 'Bunda').toString();
            avatarUrl = data['avatar_url'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error load data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, maxHeight: 500, imageQuality: 70,
      );
      
      if (pickedFile == null) return; 

      setState(() => _isUploading = true);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final file = File(pickedFile.path);
      final fileExtension = pickedFile.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension'; 

      await Supabase.instance.client.storage.from('avatars').upload(fileName, file);
      final String publicUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() => avatarUrl = publicUrl);
    } catch (e) {
      debugPrint("Gagal update foto: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      body: RefreshIndicator(
        color: navyDark,
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildProfileMenu(),
              const SizedBox(height: 25),
              _buildLogoutButton(),
              const SizedBox(height: 25),
              // INFO VERSI
              Text(
                "Versi 1.0.2", 
                style: TextStyle(
                  color: navyDark.withOpacity(0.4), 
                  fontSize: 12, 
                  fontWeight: FontWeight.w500
                )
              ),
              // --- JARAK AMAN AGAR TIDAK KETUTUP WRAPPER ---
              const SizedBox(height: 150), 
            ],
          ),
        ),
      ),
    );
  }

  // --- BAGIAN ATAS (FOTO & NAMA) ---
  Widget _buildHeader() { 
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40), 
          bottomRight: Radius.circular(40)
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: softPink,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: _isUploading
                      ? CircularProgressIndicator(color: navyDark)
                      : (avatarUrl == null ? Icon(Icons.person, size: 55, color: navyDark) : null),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: highlightPink, 
                      shape: BoxShape.circle, 
                      border: Border.all(color: navyDark, width: 3)
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: navyDark, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(namaUser, style: TextStyle(color: softPink, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: highlightPink.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              nomorTelepon, 
              style: TextStyle(color: softPink.withOpacity(0.8), fontSize: 13, letterSpacing: 1)
            ),
          ),
        ],
      ),
    );
  }

  // --- LIST MENU ---
  Widget _buildProfileMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pengaturan Akun", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          _buildMenuItem(Icons.edit_note_rounded, "Ubah Data Profil", () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            _loadUserData(); 
          }),
          _buildMenuItem(Icons.child_friendly_rounded, "Daftar Anak Bunda", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnakScreen()));
          }),
          _buildMenuItem(Icons.help_outline_rounded, "Pusat Bantuan", () {
            // Aksi bantuan
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: fieldPink.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: softPink, size: 20),
        ),
        title: Text(title, style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: navyDark),
        onTap: onTap,
      ),
    );
  }

  // --- TOMBOL KELUAR ---
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.door_back_door_outlined), // Ikon pintu keluar
            SizedBox(width: 10),
            Text("Keluar dari Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // --- DIALOG KONFIRMASI KELUAR ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Bunda yakin ingin keluar?", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold)),
        content: Text("Pastikan semua data pertumbuhan si kecil sudah tersimpan ya.", style: TextStyle(color: navyDark)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: navyDark))),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400], 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}