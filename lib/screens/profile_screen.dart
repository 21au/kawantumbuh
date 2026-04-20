import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'privacy_policy_screen.dart';
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

  Future<void> _hubungiAdmin(String pesanSpesifik) async {
    final String nomorAdmin = "6282143544981"; 
    final Uri url = Uri.parse("https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(pesanSpesifik)}");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "Tidak bisa membuka WhatsApp";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal membuka WhatsApp. Pastikan WhatsApp sudah terinstal ya, Bunda."), 
            backgroundColor: highlightPink,
          ),
        );
      }
    }
  }

  // --- BUKA LINK KEBIJAKAN PRIVASI ---
  Future<void> _bukaLinkKebijakan() async {
    // TODO: Ganti dengan link website asli Kawan Tumbuh nanti
    final Uri url = Uri.parse("https://www.google.com"); 
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _tampilkanPilihanBantuan(BuildContext context) {
    // (Kode pop-up WA admin tidak berubah dari sebelumnya)
    showModalBottomSheet(
      context: context,
      backgroundColor: softPink,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apa yang bisa kami bantu, Bunda?", style: TextStyle(color: navyDark, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Pilih topik kendala agar kami bisa cepat membantu:", style: TextStyle(color: navyDark.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 20),
              _buildOpsiBantuan(icon: Icons.phone_android_rounded, judul: "Ganti Nomor Handphone", pesan: "Halo Admin KawanTumbuh, nomor HP saya sudah tidak aktif..."),
              _buildOpsiBantuan(icon: Icons.child_care_rounded, judul: "Kendala Data Anak", pesan: "Halo Admin KawanTumbuh, saya mengalami kesulitan..."),
              _buildOpsiBantuan(icon: Icons.help_outline_rounded, judul: "Pertanyaan Lainnya", pesan: "Halo Admin KawanTumbuh, saya ingin bertanya..."),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  Widget _buildOpsiBantuan({required IconData icon, required String judul, required String pesan}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: fieldPink.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: navyDark),
        title: Text(judul, style: TextStyle(color: navyDark, fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: navyDark.withOpacity(0.5)),
        onTap: () {
          Navigator.pop(context); 
          _hubungiAdmin(pesan);   
        },
      ),
    );
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
              _buildProfileMenu(), // Menu Akun & Tentang sudah digabung di sini
              const SizedBox(height: 35),
              _buildLogoutButton(),
              const SizedBox(height: 20),
              // INFO VERSI (Lebih Rapi)
              Text("Kawan Tumbuh v1.0.2", style: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.bold)),
              Text("Dibuat dengan ❤️ untuk Bunda", style: TextStyle(color: navyDark.withOpacity(0.4), fontSize: 11)),
              const SizedBox(height: 150), 
            ],
          ),
        ),
      ),
    );
  }

  // --- BAGIAN ATAS (FOTO & NAMA) ---
  Widget _buildHeader() { 
    // (Kode Header tidak berubah)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(color: navyDark, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 55, backgroundColor: softPink, backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: _isUploading ? CircularProgressIndicator(color: navyDark) : (avatarUrl == null ? Icon(Icons.person, size: 55, color: navyDark) : null),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: highlightPink, shape: BoxShape.circle, border: Border.all(color: navyDark, width: 3)),
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
            decoration: BoxDecoration(color: highlightPink.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(nomorTelepon, style: TextStyle(color: softPink.withOpacity(0.8), fontSize: 13, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  // --- LIST MENU YANG SUDAH DIKATEGORIKAN ---
  Widget _buildProfileMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORI 1: AKUN
          Text("Akun Bunda", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildMenuItem(Icons.edit_note_rounded, "Data Profil", () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            _loadUserData(); 
          }),
          _buildMenuItem(Icons.child_friendly_rounded, "Daftar Anak Bunda", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnakScreen()));
          }),
          
          const SizedBox(height: 20),

          // KATEGORI 2: BANTUAN & TENTANG
          Text("Bantuan & Tentang", style: TextStyle(color: navyDark, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildMenuItem(Icons.help_outline_rounded, "Pusat Bantuan", () {
            _tampilkanPilihanBantuan(context);
          }),
          _buildMenuItem(Icons.privacy_tip_outlined, "Kebijakan Privasi", () {
  // Buka halaman Kebijakan Privasi
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())
  );
}),
          _buildMenuItem(Icons.star_border_rounded, "Beri Nilai Aplikasi", () {
            // TODO: Arahkan ke link Play Store
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Rate App segera hadir!")));
          }),
          
          // MENU SPESIAL: HAPUS AKUN (Warna Merah)
          _buildMenuItem(
            Icons.delete_forever_rounded, 
            "Hapus Akun Permanen", 
            () => _showDeleteAccountDialog(context),
            isDanger: true, // Parameter baru untuk bikin warna teks jadi merah
          ),
        ],
      ),
    );
  }

  // Parameter isDanger ditambahkan untuk membedakan menu hapus akun
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    final Color itemColor = isDanger ? Colors.red[600]! : navyDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: fieldPink.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isDanger ? Colors.red[100] : navyDark, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: isDanger ? Colors.red[600] : softPink, size: 20),
        ),
        title: Text(title, style: TextStyle(color: itemColor, fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: itemColor.withOpacity(0.5)),
        onTap: onTap,
      ),
    );
  }

  // --- TOMBOL KELUAR ---
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red[400]!, width: 2), // Biar beda dari tombol biasa
          foregroundColor: Colors.red[400],
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.door_back_door_outlined),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG HAPUS AKUN (DANGER ZONE) ---
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[600]),
            const SizedBox(width: 8),
            Expanded(child: Text("Hapus Akun?", style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: Text(
          "Apakah Bunda yakin ingin menghapus akun secara permanen? Semua data pertumbuhan anak dan profil akan hilang dan tidak dapat dikembalikan.", 
          style: TextStyle(color: navyDark, height: 1.4)
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: navyDark))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Panggil fungsi hapus data Supabase di sini
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hubungi Admin untuk proses penghapusan data.")));
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Hapus Permanen", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}